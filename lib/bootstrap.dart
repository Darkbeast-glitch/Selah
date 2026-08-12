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

/// Composition root.
///
/// Everything that must be ready before the first frame happens here, in order:
///
/// 1. Bind the Flutter engine.
/// 2. Load local preferences (onboarding flag, theme mode, cached translation).
/// 3. Initialise Firebase.
/// 4. Silently resolve the session, signing in anonymously if there isn't one —
///    PRD §20: no mandatory login screen, the Firebase UID is the application
///    identity.
/// 5. Install the resolved singletons as `ProviderScope` overrides.
/// 6. Run the app.
///
/// Because this awaits before `runApp`, the native launch screen covers startup
/// and the Dart side needs no splash widget.
///
/// Step 4 is deliberately *not* fatal. Auth needs the network, and a user who
/// opens Selah offline must still reach their saved Scriptures and reflections
/// (PRD §37). If sign-in fails the app starts anyway; features that need a uid
/// surface their own error state, and auth retries on the next launch.
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

  try {
    await container.read(authRepositoryProvider).ensureSignedIn();
  } on Object catch (error, stackTrace) {
    debugPrint('[bootstrap] anonymous sign-in failed: $error');
    if (kDebugMode) debugPrintStack(stackTrace: stackTrace);
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
