import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/preferences_service.dart';
import 'features/auth/data/auth_repository.dart';
import 'firebase_options.dart';

/// How long startup will wait for a session before showing UI anyway.
///
/// Sign-in is a network round-trip. Blocking the first frame on it means the OS
/// has nothing of ours to draw for as long as the network takes — during which
/// Android shows the *previous run's* task snapshot, which reads to the user as
/// "the app opened frozen on the Home screen, then flashed a splash, then
/// started". Startup must be bounded by us, not by the network.
///
/// Short enough to be imperceptible on a good connection, long enough that a
/// warm session is usually resolved before the first frame.
const _sessionWarmupBudget = Duration(milliseconds: 800);

/// Composition root.
///
/// Only work that is **local and fast** may block the first frame:
///
/// 1. Bind the Flutter engine.
/// 2. Load local preferences (onboarding flag, theme mode, cached translation).
/// 3. Initialise Firebase — local setup, no network.
/// 4. *Start* anonymous sign-in, and wait at most [_sessionWarmupBudget] for it.
/// 5. Run the app.
///
/// The native launch screen covers this, so the Dart side needs no splash
/// widget — but only because steps 1–4 are bounded. Never add an unbounded
/// `await` here; put it behind a provider and let the UI show a loading state.
///
/// Sign-in is deliberately *not* awaited to completion and *not* fatal:
///
/// * Auth needs the network, and an offline user must still reach their saved
///   Scriptures and reflections (PRD §37).
/// * If it is still in flight when the budget expires, the app starts anyway
///   and `uidChangesProvider` delivers the uid the moment it lands — the
///   Firestore-backed providers rebuild themselves at that point.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // TODO(milestone-5): forward to Crashlytics.
  };

  final preferences = PreferencesService(await SharedPreferences.getInstance());

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final container = ProviderContainer(
    overrides: [preferencesServiceProvider.overrideWithValue(preferences)],
    observers: kDebugMode ? [_ProviderLogger()] : null,
  );

  // Start sign-in, then attach a handler immediately. Without this, a failure
  // arriving after the budget expires would surface as an unhandled async error
  // with no owner.
  final session = container.read(authRepositoryProvider).ensureSignedIn();
  unawaited(
    session.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('[bootstrap] anonymous sign-in failed: $error');
        if (kDebugMode) debugPrintStack(stackTrace: stackTrace);
      },
    ),
  );

  // Give it a brief head start so the common case has a uid before the first
  // frame — but never hold the app hostage to the network.
  try {
    await session.timeout(_sessionWarmupBudget);
  } on Object {
    // Timed out or failed. Either way the app starts now; the session arrives
    // later through the auth stream, or on the next launch.
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const SelahApp(),
    ),
  );
}

/// Logs provider failures in debug builds so a thrown repository error is never
/// swallowed silently during development.
final class _ProviderLogger extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    debugPrint('[provider] ${context.provider.name ?? context.provider.runtimeType} failed: $error');
  }
}
