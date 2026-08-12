import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_shell.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/section_label.dart';

/// Explore — browse Scripture by topic, or search it directly (PRD §14).
///
/// Design: `selah_scripture_companion/explore/`.
///
/// Structural scaffold: the search field is inert and "Popular passages" is
/// empty until Scripture search arrives in Milestone 2. An `ExploreViewModel`
/// will own the query state and results.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.only(
            left: AppSpacing.containerMargin,
            right: AppSpacing.containerMargin,
            top: AppSpacing.stackLg,
            bottom: AppShell.bottomInset(context) + AppSpacing.sectionGap,
          ),
          children: [
            Text(AppStrings.exploreTitle, style: context.text.headlineLarge),
            const SizedBox(height: AppSpacing.stackLg),

            // TODO(milestone-2): wire to the Scripture search view model.
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: AppStrings.exploreSearchHint,
                prefixIcon: const Icon(Icons.search_rounded),
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.exploreTopicsLabel),
            const SizedBox(height: AppSpacing.stackMd),
            for (final group in ExploreGroup.values) ...[
              _TopicGroup(group: group),
              const SizedBox(height: AppSpacing.stackLg),
            ],
          ],
        ),
      ),
    );
  }
}

class _TopicGroup extends StatelessWidget {
  const _TopicGroup({required this.group});

  final ExploreGroup group;

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
                // TODO(milestone-2): open topic results.
                ActionChip(label: Text(topic), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
