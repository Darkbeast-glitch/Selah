import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/preferences_service.dart';
import '../features/conversation/view/conversation_screen.dart';
import '../features/explore/view/explore_screen.dart';
import '../features/home/view/home_screen.dart';
import '../features/library/view/library_screen.dart';
import '../features/onboarding/view/onboarding_screen.dart';
import '../features/prayer/view/prayer_screen.dart';
import '../features/profile/view/profile_screen.dart';
import '../features/reflection/view/reflection_screen.dart';
import '../features/scripture/view/scripture_detail_screen.dart';
import 'app_shell.dart';

/// Route names. Always navigate by name (`context.goNamed(AppRoute.home.name)`)
/// so path changes stay in one file.
enum AppRoute {
  onboarding('/onboarding'),
  home('/home'),
  explore('/explore'),
  library('/library'),
  profile('/profile'),

  /// `/conversation` starts a new conversation; `/conversation/:id` resumes one
  /// from History.
  conversation('/conversation'),

  /// `/scripture/:scriptureId` — the distraction-free reader.
  scripture('/scripture/:scriptureId'),

  /// `/reflection?scriptureId=...`
  reflection('/reflection'),

  /// `/prayer?reflectionId=...` — the prayer starter.
  prayer('/prayer');

  const AppRoute(this.path);
  final String path;
}

/// Builds the app's router.
///
/// Structure: a [StatefulShellRoute] holds the four bottom-nav branches so each
/// tab keeps its own navigation stack and scroll position. Conversation,
/// reader, reflection, and prayer push *over* the shell — they are focused,
/// full-screen moments and should not show the nav bar.
final routerProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);

  return GoRouter(
    initialLocation: prefs.onboardingComplete
        ? AppRoute.home.path
        : AppRoute.onboarding.path,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: AppRoute.onboarding.path,
        name: AppRoute.onboarding.name,
        builder: (context, state) => const OnboardingScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.home.path,
                name: AppRoute.home.name,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.explore.path,
                name: AppRoute.explore.name,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.library.path,
                name: AppRoute.library.name,
                builder: (context, state) => const LibraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoute.profile.path,
                name: AppRoute.profile.name,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: AppRoute.conversation.path,
        name: AppRoute.conversation.name,
        builder: (context, state) => ConversationScreen(
          conversationId: state.uri.queryParameters['id'],
          openingMessage: state.uri.queryParameters['message'],
        ),
      ),
      GoRoute(
        path: AppRoute.scripture.path,
        name: AppRoute.scripture.name,
        builder: (context, state) => ScriptureDetailScreen(
          scriptureId: state.pathParameters['scriptureId']!,
        ),
      ),
      GoRoute(
        path: AppRoute.reflection.path,
        name: AppRoute.reflection.name,
        builder: (context, state) => ReflectionScreen(
          scriptureId: state.uri.queryParameters['scriptureId'],
          reflectionId: state.uri.queryParameters['reflectionId'],
        ),
      ),
      GoRoute(
        path: AppRoute.prayer.path,
        name: AppRoute.prayer.name,
        builder: (context, state) => PrayerScreen(
          reflectionId: state.uri.queryParameters['reflectionId'],
          prayerId: state.uri.queryParameters['prayerId'],
          scriptureId: state.uri.queryParameters['scriptureId'],
          seed: state.uri.queryParameters['seed'],
        ),
      ),
    ],
  );
});
