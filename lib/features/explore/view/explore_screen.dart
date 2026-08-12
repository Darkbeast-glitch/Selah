import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_shell.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/state_views.dart';
import '../../scripture/data/models/scripture.dart';
import '../../scripture/data/scripture_repository.dart';
import '../viewmodel/explore_search_controller.dart';

/// Explore — search Scripture, or browse it by topic (PRD §13, §14).
///
/// Design: `selah_scripture_companion/explore/`. One field serves references,
/// book names, and keywords; the categories below are the way in when you don't
/// have words yet.
class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String value) =>
      ref.read(exploreSearchProvider.notifier).search(value);

  void _searchTopic(String topic) {
    _controller.text = topic;
    _submit(topic);
  }

  void _clear() {
    _controller.clear();
    ref.read(exploreSearchProvider.notifier).clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(exploreSearchProvider);
    final hasQuery = results.value != null || results.isLoading;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(
            left: AppSpacing.containerMargin,
            right: AppSpacing.containerMargin,
            top: AppSpacing.stackLg,
            bottom: AppShell.bottomInset(context) + AppSpacing.sectionGap,
          ),
          children: [
            Text(AppStrings.exploreTitle, style: context.text.headlineLarge),
            const SizedBox(height: AppSpacing.stackLg),

            TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: _submit,
              decoration: InputDecoration(
                hintText: AppStrings.exploreSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: hasQuery
                    ? IconButton(
                        onPressed: _clear,
                        icon: const Icon(Icons.close_rounded),
                        tooltip: 'Clear',
                      )
                    : null,
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // Results replace the categories while a search is active, so the
            // screen has one subject at a time.
            if (hasQuery)
              _Results(results: results)
            else
              _Categories(onTopic: _searchTopic),
          ],
        ),
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results({required this.results});

  final AsyncValue<SearchOutcome?> results;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return results.when(
      loading: () => const Padding(
        padding: EdgeInsets.only(top: AppSpacing.sectionGap),
        child: LoadingView(message: AppStrings.loadingScripture),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.only(top: AppSpacing.stackLg),
        child: ErrorView(
          message: '$error',
          onRetry: () => ref
              .read(exploreSearchProvider.notifier)
              .search(ref.read(exploreSearchProvider.notifier).query),
        ),
      ),
      data: (outcome) => switch (outcome) {
        null => const SizedBox.shrink(),

        // A named passage: label it as such so the user knows the app
        // understood a reference rather than matching words.
        ReferenceMatch(:final ref, :final scriptures) => _ResultList(
          label: ref.verse == null
              ? '${ref.book} ${ref.chapter}'
              : '${ref.book} ${ref.chapter}:${ref.verse}',
          scriptures: scriptures,
        ),

        KeywordMatch(:final query, :final scriptures, :final total) =>
          _ResultList(
            label: '$total ${total == 1 ? 'result' : 'results'} for "$query"',
            scriptures: scriptures,
            onLoadMore: scriptures.length < total
                ? () => ref.read(exploreSearchProvider.notifier).loadMore()
                : null,
          ),

        NoMatch(:final query) => EmptyView(
          title: 'Nothing found for "$query"',
          body: 'Try a different word, a topic, or a passage like John 3:16.',
          icon: Icons.search_off_rounded,
        ),
      },
    );
  }
}

class _ResultList extends StatelessWidget {
  const _ResultList({
    required this.label,
    required this.scriptures,
    this.onLoadMore,
  });

  final String label;
  final List<Scripture> scriptures;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(label),
        const SizedBox(height: AppSpacing.stackMd),
        for (final scripture in scriptures) ...[
          ScriptureCard(
            reference: scripture.reference,
            text: scripture.text,
            translation: scripture.translation,
            compact: true,
            onOpen: () => context.pushNamed(
              AppRoute.scripture.name,
              pathParameters: {'scriptureId': scripture.id},
            ),
          ),
          const SizedBox(height: AppSpacing.stackSm),
        ],
        if (onLoadMore != null) ...[
          const SizedBox(height: AppSpacing.stackMd),
          OutlinedButton(
            onPressed: onLoadMore,
            child: const Text('Show more'),
          ),
        ],
      ],
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({required this.onTopic});

  final ValueChanged<String> onTopic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(AppStrings.exploreTopicsLabel),
        const SizedBox(height: AppSpacing.stackMd),
        for (final group in ExploreGroup.values) ...[
          _TopicGroup(group: group, onTopic: onTopic),
          const SizedBox(height: AppSpacing.stackLg),
        ],
      ],
    );
  }
}

class _TopicGroup extends StatelessWidget {
  const _TopicGroup({required this.group, required this.onTopic});

  final ExploreGroup group;
  final ValueChanged<String> onTopic;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: context.colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(group.label, style: context.text.headlineMedium),
          const SizedBox(height: AppSpacing.stackMd),
          Wrap(
            spacing: AppSpacing.stackSm,
            runSpacing: AppSpacing.stackSm,
            children: [
              for (final topic in group.topics)
                // A topic is currently just a keyword search — honest about what
                // it does. Thematic curation needs the Milestone 3 backend.
                ActionChip(
                  label: Text(topic),
                  onPressed: () => onTopic(topic),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
