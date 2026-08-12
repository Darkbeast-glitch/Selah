import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_strings.dart';
import 'app_theme.dart';

/// Holds the four bottom-nav destinations.
///
/// DESIGN.md: the nav bar is a translucent blur (glassmorphism) over the
/// content, with a 0.5px top border and forest-green icons in the active state.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    _Destination(AppStrings.navHome, Icons.wb_twilight_outlined, Icons.wb_twilight_rounded),
    _Destination(AppStrings.navExplore, Icons.search_outlined, Icons.search_rounded),
    _Destination(AppStrings.navLibrary, Icons.bookmark_border_rounded, Icons.bookmark_rounded),
    _Destination(AppStrings.navProfile, Icons.person_outline_rounded, Icons.person_rounded),
  ];

  void _onTap(int index) => navigationShell.goBranch(
    index,
    // Tapping the active tab returns it to its root.
    initialLocation: index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The nav bar floats over content, so the body extends beneath it and
      // screens add their own bottom padding via [AppShell.bottomInset].
      extendBody: true,
      body: navigationShell,
      bottomNavigationBar: _GlassNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        destinations: _destinations,
      ),
    );
  }

  /// Bottom padding a scrollable screen should add so its last item clears the
  /// translucent nav bar.
  static double bottomInset(BuildContext context) =>
      72 + MediaQuery.viewPaddingOf(context).bottom;
}

class _Destination {
  const _Destination(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_Destination> destinations;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.82),
            border: Border(
              top: BorderSide(color: colors.outlineVariant, width: 0.5),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackSm),
              child: Row(
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    Expanded(
                      child: _NavItem(
                        destination: destinations[i],
                        selected: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final _Destination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = selected ? colors.primary : colors.outline;

    return Semantics(
      button: true,
      selected: selected,
      label: destination.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.stackSm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                selected ? destination.selectedIcon : destination.icon,
                size: 24,
                color: color,
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                style: AppTypography.navLabel.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
