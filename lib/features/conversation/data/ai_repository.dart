import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../auth/data/auth_repository.dart';
import '../../scripture/data/models/scripture.dart';
import '../../scripture/data/scripture_repository.dart';
import 'ai_datasource.dart';
import 'models/ai_models.dart';

/// A complete conversation turn: what the user said, the passages retrieved for
/// it locally, and — if the backend is reachable — the reflection on them.
///
/// [reflection] being null is a first-class state, not a failure: with no
/// backend configured, offline, or out of quota, the turn still shows real
/// Scripture. That degradation is the point (§37).
class ConversationTurn {
  const ConversationTurn({
    required this.message,
    required this.passages,
    this.reflection,
  });

  final String message;
  final List<Scripture> passages;
  final AiReflection? reflection;
}

abstract interface class AiRepository {
  /// True when this build has a backend to talk to.
  bool get isAvailable;

  /// Retrieves passages locally, then asks the backend to reflect on them.
  ///
  /// Retrieval happens here rather than in the backend so it works offline and
  /// costs nothing — and so the model can only ever comment on Scripture the
  /// app chose.
  Future<ConversationTurn> reflectOn(
    String message, {
    List<({String role, String content})> history = const [],
  });

  Future<AiPrayer> prayerFor({
    required String reflection,
    required Scripture passage,
  });

  /// Retrieval only — no backend call, no cost. Used when restoring a thread
  /// from History, where the replies were already read once.
  Future<ConversationTurn> passagesOnlyFor(String message);
}

class BackendAiRepository implements AiRepository {
  /// See `library_repository.dart` — `this._dataSource` as a named parameter is
  /// illegal in Dart, so the lint's suggested fix does not compile.
  // ignore_for_file: prefer_initializing_formals
  BackendAiRepository({
    required AiDataSource dataSource,
    required ScriptureRepository scripture,
  })  : _dataSource = dataSource,
        _scripture = scripture;

  final AiDataSource _dataSource;
  final ScriptureRepository _scripture;

  @override
  bool get isAvailable => AppConfig.isAiConfigured;

  @override
  Future<ConversationTurn> reflectOn(
    String message, {
    List<({String role, String content})> history = const [],
  }) async {
    final passages = await _scripture.passagesFor(message);

    // No passages means nothing for the model to comment on, and asking it to
    // fill the gap is exactly the fabrication §24 forbids. Return the empty
    // turn and let the UI say so plainly.
    if (passages.isEmpty || !isAvailable) {
      return ConversationTurn(message: message, passages: passages);
    }

    final reflection = await _dataSource.reflect(
      message: message,
      passages: passages,
      history: history,
    );
    return ConversationTurn(
      message: message,
      passages: passages,
      reflection: reflection,
    );
  }

  @override
  Future<AiPrayer> prayerFor({
    required String reflection,
    required Scripture passage,
  }) =>
      _dataSource.prayer(reflection: reflection, passage: passage);

  @override
  Future<ConversationTurn> passagesOnlyFor(String message) async =>
      ConversationTurn(
        message: message,
        passages: await _scripture.passagesFor(message),
      );
}

// ------------------------------------------------------------- providers ---

final aiDataSourceProvider = Provider<AiDataSource>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final dataSource = AiDataSource(idToken: auth.idToken);
  ref.onDispose(dataSource.close);
  return dataSource;
});

final aiRepositoryProvider = Provider<AiRepository>(
  (ref) => BackendAiRepository(
    dataSource: ref.watch(aiDataSourceProvider),
    scripture: ref.watch(scriptureRepositoryProvider),
  ),
);
