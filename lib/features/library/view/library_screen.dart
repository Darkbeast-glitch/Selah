import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_shell.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/state_views.dart';

/// Library — everything the user has kept (PRD §16).
///
/// Design: `selah_scripture_companion/library/`. Two tabs: saved Scriptures and
/// conversation history.
///
/// Structural scaffold: both tabs render their empty state. A `LibraryViewModel`
/// will supply paginated bookmarks and conversations in Milestone 4.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.containerMargin,
                  AppSpacing.stackLg,
                  AppSpacing.containerMargin,
                  AppSpacing.stackMd,
                ),
                child: Text(
                  AppStrings.libraryTitle,
                  style: context.text.headlineLarge,
                ),
              ),
              TabBar(
                labelColor: context.colors.primary,
                unselectedLabelColor: context.colors.outline,
                indicatorColor: context.colors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: context.colors.outlineVariant,
                tabs: const [
                  Tab(text: AppStrings.librarySavedTab),
                  Tab(text: AppStrings.libraryHistoryTab),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: AppShell.bottomInset(context),
                  ),
                  child: const TabBarView(
                    children: [
                      // TODO(milestone-4): bookmarks list from the library
                      // repository, paginated.
                      EmptyView(
                        title: AppStrings.emptyLibraryTitle,
                        body: AppStrings.emptyLibraryBody,
                        icon: Icons.bookmark_border_rounded,
                      ),
                      // TODO(milestone-4): conversation history, paginated.
                      EmptyView(
                        title: AppStrings.emptyHistoryTitle,
                        body: AppStrings.emptyHistoryBody,
                        icon: Icons.forum_outlined,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
