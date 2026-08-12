import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/preferences_service.dart';

/// Composition root.
///
/// Everything that must be ready before the first frame happens here, in order:
///
/// 1. Bind the Flutter engine.
/// 2. Load local preferences (onboarding flag, theme mode, cached translation).
/// 3. *(Milestone 1)* Initialise Firebase and silently sign the user in
///    anonymously — PRD §20: no mandatory login screen, the Firebase UID becomes
///    the application identity.
/// 4. Install the resolved singletons as `ProviderScope` overrides.
/// 5. Run the app.
///
/// Because this awaits before `runApp`, the native launch screen covers startup
/// and the Dart side needs no splash widget.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    // TODO(milestone-5): forward to Crashlytics once Firebase is configured.
  };

  final preferences = PreferencesService(await SharedPreferences.getInstance());

  // TODO(milestone-1): once `flutterfire configure` has generated
  // `firebase_options.dart`, initialise Firebase and resolve the anonymous
  // session here, then override the auth provider below:
  //
  //   await Firebase.initializeApp(
  //     options: DefaultFirebaseOptions.currentPlatform,
  //   );
  //   final auth = FirebaseAuth.instance;
  //   final user = auth.currentUser ?? (await auth.signInAnonymously()).user;

  runApp(
    ProviderScope(
      overrides: [
        preferencesServiceProvider.overrideWithValue(preferences),
      ],
      observers: kDebugMode ? [_ProviderLogger()] : null,
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
