import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Local key–value storage for device-scoped settings.
///
/// This is a *data source*: it owns the `SharedPreferences` API and nothing
/// else. User-scoped data (translation choice, bookmarks, reflections) belongs
/// in Firestore under `users/{uid}` — keep only device preferences here, such as
/// whether onboarding has been seen and the chosen theme mode.
class PreferencesService {
  const PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  static const _keyOnboardingComplete = 'onboarding_complete';
  static const _keyThemeMode = 'theme_mode';
  static const _keyTranslation = 'translation';

  bool get onboardingComplete =>
      _prefs.getBool(_keyOnboardingComplete) ?? false;

  Future<void> setOnboardingComplete({required bool value}) =>
      _prefs.setBool(_keyOnboardingComplete, value);

  ThemeMode get themeMode {
    final stored = _prefs.getString(_keyThemeMode);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_keyThemeMode, mode.name);

  /// Cached copy of the user's translation so the reader can render offline
  /// before Firestore resolves (PRD §37).
  String get translation =>
      _prefs.getString(_keyTranslation) ?? AppConstants.defaultTranslation;

  Future<void> setTranslation(String code) =>
      _prefs.setString(_keyTranslation, code);
}

/// Resolved during app startup — see `app/app_startup.dart`. Overridden with a
/// real instance in `ProviderScope`, so reading it before startup completes is
/// a programming error rather than a silent default.
final preferencesServiceProvider = Provider<PreferencesService>(
  (ref) => throw UnimplementedError(
    'preferencesServiceProvider must be overridden during app startup.',
  ),
);

/// The user's appearance preference (PRD §19 → Preferences → Appearance).
class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.read(preferencesServiceProvider).themeMode;

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(preferencesServiceProvider).setThemeMode(mode);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
