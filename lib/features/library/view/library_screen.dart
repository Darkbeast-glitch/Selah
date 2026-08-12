import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_shell.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/state_views.dart';
import '../data/library_repository.dart';

/// Library — everything the user has kept (PRD §16).
///
/// Design: `selah_scripture_companion/library/`. Tabs for saved Scripture and
/// what the user has written.
///
/// The History tab is still empty: conversation persistence is the remaining
/// part of Milestone 4. Reflections stand in as the "what I've written" view for
/// now, which is honest — there is no fabricated history list.
class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
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
                  Tab(text: AppStrings.profileReflections),
                  Tab(text: AppStrings.profilePrayers),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: AppShell.bottomInset(context),
                  ),
                  child: const TabBarView(
                    children: [_SavedTab(), _ReflectionsTab(), _PrayersTab()],
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

class _SavedTab extends ConsumerWidget {
  const _SavedTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(bookmarksProvider);

    return bookmarks.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: '$error',
        onRetry: () => ref.invalidate(bookmarksProvider),
      ),
      data: (items) => items.isEmpty
          ? const EmptyView(
              title: AppStrings.emptyLibraryTitle,
              body: AppStrings.emptyLibraryBody,
              icon: Icons.bookmark_border_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.stackSm),
              itemBuilder: (context, index) {
                final item = items[index];
                final scripture = item.scripture;

                // A saved id missing from the corpus: say so rather than
                // rendering a blank card.
                if (scripture == null) {
                  return _MissingPassage(scriptureId: item.bookmark.scriptureId);
                }

                return ScriptureCard(
                  reference: scripture.reference,
                  text: scripture.text,
                  translation: scripture.translation,
                  compact: true,
                  onOpen: () => context.pushNamed(
                    AppRoute.scripture.name,
                    pathParameters: {'scriptureId': scripture.id},
                  ),
                );
              },
            ),
    );
  }
}

class _ReflectionsTab extends ConsumerWidget {
  const _ReflectionsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reflections = ref.watch(reflectionsProvider);

    return reflections.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: '$error',
        onRetry: () => ref.invalidate(reflectionsProvider),
      ),
      data: (items) => items.isEmpty
          ? const EmptyView(
              title: 'Nothing written yet.',
              body: 'Open a passage and tap "Reflect on this passage" to keep '
                  'your thoughts here. Reflections are private.',
              icon: Icons.edit_note_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.stackMd),
              itemBuilder: (context, index) {
                final item = items[index];
                return _WrittenCard(
                  reference: item.scripture?.reference,
                  content: item.reflection.content,
                  date: item.reflection.updatedAt,
                  onTap: () => context.pushNamed(
                    AppRoute.reflection.name,
                    queryParameters: {
                      'reflectionId': item.reflection.id,
                      'scriptureId': item.reflection.scriptureId,
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _PrayersTab extends ConsumerWidget {
  const _PrayersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayers = ref.watch(prayersProvider);

    return prayers.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: '$error',
        onRetry: () => ref.invalidate(prayersProvider),
      ),
      data: (items) => items.isEmpty
          ? const EmptyView(
              title: 'No prayers kept yet.',
              body: 'Turn a reflection into a prayer starter and it will '
                  'appear here.',
              icon: Icons.self_improvement_outlined,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.containerMargin),
              itemCount: items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.stackMd),
              itemBuilder: (context, index) {
                final item = items[index];
                return _WrittenCard(
                  reference: item.scripture?.reference,
                  content: item.prayer.content,
                  date: item.prayer.createdAt,
                  isPrayer: true,
                );
              },
            ),
    );
  }
}

/// A reflection or prayer the user wrote.
///
/// Prayers use the forest-green surface from DESIGN.md so "my prayer" stays
/// visually distinct from "God's Word" on a Scripture card.
class _WrittenCard extends StatelessWidget {
  const _WrittenCard({
    required this.content,
    required this.date,
    this.reference,
    this.isPrayer = false,
    this.onTap,
  });

  final String content;
  final DateTime date;
  final String? reference;
  final bool isPrayer;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: isPrayer
            ? context.colors.primaryContainer
            : context.colors.surfaceContainerLow,
        borderRadius: AppRadius.cardRadius,
        border: isPrayer
            ? null
            : Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (reference case final ref?)
                Expanded(
                  child: SectionLabel(
                    ref,
                    color: isPrayer
                        ? context.selahColors.primaryFixedDim
                        : context.colors.primary,
                  ),
                )
              else
                const Spacer(),
              Text(
                AppDateUtils.relativeLabel(date),
                style: context.text.labelSmall?.copyWith(
                  color: isPrayer
                      ? context.selahColors.primaryFixedDim
                      : context.colors.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.stackMd),
          Text(
            content,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: (isPrayer
                    ? AppTypography.bodyLg
                    : AppTypography.bodyMd)
                .copyWith(
              color: isPrayer
                  ? context.colors.onPrimaryContainer
                  : context.colors.onSurface,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.cardRadius,
        child: card,
      ),
    );
  }
}

class _MissingPassage extends StatelessWidget {
  const _MissingPassage({required this.scriptureId});

  final String scriptureId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Text(
        'This passage is not in the current Scripture library ($scriptureId).',
        style: context.text.bodySmall,
      ),
    );
  }
}
