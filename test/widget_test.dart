import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selah/app/app.dart';
import 'package:selah/core/constants/app_strings.dart';
import 'package:selah/core/services/preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Smoke tests for the app shell.
///
/// These pin the two structural guarantees of Milestone 1: a first launch lands
/// on onboarding, and a returning user lands on Home with the four nav
/// destinations present. Screen-level widget tests (PRD §40) arrive with each
/// feature's ViewModel.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    required bool onboardingComplete,
  }) async {
    SharedPreferences.setMockInitialValues({
      'onboarding_complete': onboardingComplete,
    });
    final prefs = PreferencesService(await SharedPreferences.getInstance());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesServiceProvider.overrideWithValue(prefs)],
        child: const SelahApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('first launch opens onboarding', (tester) async {
    await pumpApp(tester, onboardingComplete: false);

    expect(find.text(AppStrings.onboardingPause), findsOneWidget);
    expect(find.text(AppStrings.onboardingBegin), findsOneWidget);
  });

  testWidgets('returning user opens Home inside the nav shell', (tester) async {
    await pumpApp(tester, onboardingComplete: true);

    expect(find.text(AppStrings.homePrompt), findsOneWidget);
    for (final label in [
      AppStrings.navHome,
      AppStrings.navExplore,
      AppStrings.navLibrary,
      AppStrings.navProfile,
    ]) {
      expect(find.text(label), findsOneWidget);
    }
  });

  testWidgets('completing onboarding navigates to Home', (tester) async {
    await pumpApp(tester, onboardingComplete: false);

    await tester.tap(find.text(AppStrings.onboardingBegin));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.homePrompt), findsOneWidget);
  });
}
