import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:selah/app/app_theme.dart';
import 'package:selah/core/constants/app_strings.dart';
import 'package:selah/core/services/preferences_service.dart';
import 'package:selah/features/profile/view/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Render smoke tests.
///
/// These exist because a layout error shipped that made the whole Profile screen
/// blank: a `Row` inside `ListTile.trailing` defaults to `MainAxisSize.max`,
/// claimed the entire tile width, and the tile failed layout. Nothing in the
/// suite rendered Profile, so nothing caught it — `flutter analyze` cannot see a
/// layout constraint violation, only a test that builds the widget can.
///
/// The screens here need no backend: their Firestore-backed providers fail
/// without a session, which resolves to `AsyncError`, and each screen is
/// supposed to render its loading or error state rather than throw. That is
/// exactly the behaviour worth pinning.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester tester, Widget screen) async {
    final prefs = PreferencesService(await SharedPreferences.getInstance());

    // A tall surface so the whole scrollable is built at once. `ListView` only
    // builds visible children, so on a phone-sized viewport the About and
    // Account rows would not exist to assert against — and a test that silently
    // checks half the screen is worse than no test.
    tester.view.physicalSize = const Size(1200, 4000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [preferencesServiceProvider.overrideWithValue(prefs)],
        child: MaterialApp(theme: AppTheme.light, home: screen),
      ),
    );
    await tester.pump();
  }

  group('ProfileScreen', () {
    testWidgets('lays out without constraint violations', (tester) async {
      await pump(tester, const ProfileScreen());

      // A layout failure surfaces here as a thrown exception, which is the
      // whole point of this test.
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders every section', (tester) async {
      await pump(tester, const ProfileScreen());

      for (final label in [
        AppStrings.profileJourneyLabel,
        AppStrings.profilePreferencesLabel,
        AppStrings.profileAboutLabel,
        AppStrings.profileAccountLabel,
      ]) {
        expect(
          find.text(label.toUpperCase()),
          findsOneWidget,
          reason: 'missing section: $label',
        );
      }
    });

    testWidgets('every row is tappable', (tester) async {
      await pump(tester, const ProfileScreen());

      // The regression that prompted this: rows rendered but had no onTap, so
      // the screen looked finished and did nothing.
      final tiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(tiles, isNotEmpty);

      final dead = tiles.where((tile) => tile.onTap == null).toList();
      expect(
        dead,
        isEmpty,
        reason: '${dead.length} Profile row(s) have no onTap handler',
      );
    });

    testWidgets('destructive action is styled as destructive', (tester) async {
      await pump(tester, const ProfileScreen());

      // "Delete my data" must not look like an ordinary settings row.
      final deleteRow = tester.widget<ListTile>(
        find.ancestor(
          of: find.text(AppStrings.profileDeleteData),
          matching: find.byType(ListTile),
        ),
      );
      final title = deleteRow.title! as Text;
      expect(title.style?.color, AppTheme.light.colorScheme.error);
    });
  });
}
