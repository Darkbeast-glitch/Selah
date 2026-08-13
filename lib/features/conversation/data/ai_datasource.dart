import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/errors/app_exception.dart';
import '../../scripture/data/models/scripture.dart';
import 'models/ai_models.dart';

/// Talks to Selah's backend (`../../selah-backend/`).
///
/// The only file in the app that knows the backend's wire format. It holds no
/// credentials — it sends the Firebase ID token the app already has, and the
/// Worker holds the LLM key (PRD §22/§23).
///
/// **Passages travel app → backend, never the reverse.** The app retrieves
/// Scripture from its local corpus and supplies it; the model only comments on
/// what it is given. That is what makes "never invent a Bible verse" (§24) a
/// property of the architecture rather than a hope about the prompt.
class AiDataSource {
  /// `prefer_initializing_formals` is suppressed here for the same reason as in
  /// `library_repository.dart`: its fix (`this._idToken`) does not compile —
  /// Dart forbids named parameters that start with an underscore.
  // ignore_for_file: prefer_initializing_formals
  AiDataSource({
    required Future<String?> Function() idToken,
    http.Client? client,
    String? baseUrl,
  })  : _idToken = idToken,
        _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConfig.aiBaseUrl;

  final Future<String?> Function() _idToken;
  final http.Client _client;
  final String _baseUrl;

  Future<AiReflection> reflect({
    required String message,
    required List<Scripture> passages,
    List<({String role, String content})> history = const [],
  }) async {
    final json = await _post('/v1/reflect', {
      'message': message,
      'passages': passages.map(_passageJson).toList(),
      if (history.isNotEmpty)
        'history': history
            .map((turn) => {'role': turn.role, 'content': turn.content})
            .toList(),
    });
    return AiReflection.fromJson(json);
  }

  Future<AiPrayer> prayer({
    required String reflection,
    required Scripture passage,
  }) async {
    final json = await _post('/v1/prayer', {
      'reflection': reflection,
      'passage': _passageJson(passage),
    });
    return AiPrayer.fromJson(json);
  }

  Map<String, Object?> _passageJson(Scripture passage) => {
    'id': passage.id,
    'reference': passage.reference,
    'text': passage.text,
    'translation': passage.translation,
  };

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, Object?> body,
  ) async {
    if (_baseUrl.isEmpty) {
      throw const AiException(
        message: 'Selah\'s reflection service is not configured for this build.',
      );
    }

    final token = await _idToken();
    if (token == null) {
      // No session yet. Distinct from an auth *failure* — the app starts before
      // sign-in necessarily completes (see bootstrap.dart), so this is a
      // "try again in a moment", not "you are signed out".
      throw const AuthException(
        message: 'Selah is still starting up. Please try again in a moment.',
      );
    }

    // Debug-only tracing. Without this, a request blocked *before* it leaves the
    // device — iOS App Transport Security, or the local-network permission
    // prompt on a LAN address — is invisible: the UI just sits on its loading
    // state with nothing in the console and nothing in `wrangler tail`.
    final uri = Uri.parse('$_baseUrl$path');
    final started = DateTime.now();
    if (kDebugMode) debugPrint('[ai] POST $uri');

    late final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: {
              'authorization': 'Bearer $token',
              'content-type': 'application/json; charset=utf-8',
            },
            body: jsonEncode(body),
          )
          .timeout(AppConfig.aiTimeout);
    } on SocketException catch (error, stackTrace) {
      if (kDebugMode) debugPrint('[ai] socket failure for $uri: $error');
      throw NetworkException(cause: error, stackTrace: stackTrace);
    } on HttpException catch (error, stackTrace) {
      if (kDebugMode) debugPrint('[ai] http failure for $uri: $error');
      throw NetworkException(cause: error, stackTrace: stackTrace);
    } on TimeoutException catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint(
          '[ai] timed out after ${AppConfig.aiTimeout.inSeconds}s: $uri\n'
          '     If nothing reached the backend at all, check that the host is '
          'reachable from the device and that wrangler is bound with --ip 0.0.0.0.',
        );
      }
      throw NetworkException(
        message: 'Selah took too long to respond. Please try again.',
        cause: error,
        stackTrace: stackTrace,
      );
    } on Object catch (error, stackTrace) {
      if (kDebugMode) debugPrint('[ai] request failed for $uri: $error');
      throw NetworkException(
        message: 'Selah could not be reached. Check your connection and try again.',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (kDebugMode) {
      final ms = DateTime.now().difference(started).inMilliseconds;
      debugPrint('[ai] ${response.statusCode} in ${ms}ms ← $uri');
    }

    Map<String, dynamic> decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } on Object catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('[ai] unparseable body: ${response.body.substring(0, response.body.length.clamp(0, 300))}');
      }
      throw AiException(cause: error, stackTrace: stackTrace);
    }

    if (response.statusCode == 200) return decoded;

    final failure = _errorFor(response.statusCode, decoded);
    if (kDebugMode) debugPrint('[ai] rejected: ${failure.message}');
    throw failure;
  }

  /// Maps the backend's error contract onto the app's exception types.
  ///
  /// The backend's `message` is written to be shown to a user, so it is used
  /// directly rather than replaced with a generic string — it carries the
  /// specific, honest explanation (quota exhausted vs. daily limit vs. rejected
  /// response), and those read very differently to someone waiting.
  AppException _errorFor(int status, Map<String, dynamic> body) {
    final error = body['error'];
    final code = error is Map ? error['code'] as String? : null;
    final message = error is Map ? error['message'] as String? : null;

    return switch (code) {
      'unauthenticated' => AuthException(message: message ?? 'Session could not be verified.'),
      'daily_limit_reached' => RateLimitException(
        message: message ?? 'You have reached today\'s reflection limit.',
      ),
      // Project-wide free-tier exhaustion, not this user's fault — the message
      // says so, which is why it is passed through.
      'provider_busy' => AiException(
        message: message ?? 'Selah is at capacity right now. Please try again shortly.',
      ),
      'response_rejected' => AiException(
        message: message ?? 'Selah could not offer a response it was confident in.',
      ),
      'invalid_request' => AiException(message: message ?? 'That request could not be processed.'),
      _ => AiException(
        message: message ?? 'Selah could not respond just now. Please try again.',
        cause: 'HTTP $status',
      ),
    };
  }

  void close() => _client.close();
}
