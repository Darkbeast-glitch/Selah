import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../../core/widgets/section_label.dart';

/// The Scripture reader (PRD §15).
///
/// Design: `selah_scripture_companion/scripture_detail/`. A distraction-free
/// reading surface — chrome recedes, the text carries the page.
///
/// Structural scaffold: the passage is placeholder text. Milestone 2 supplies
/// the chapter from the Scripture repository and wires bookmark, share, copy,
/// and highlight.
class ScriptureDetailScreen extends ConsumerWidget {
  const ScriptureDetailScreen({super.key, required this.scriptureId});

  /// Verse id in the corpus, e.g. `psalm_23_1`.
  final String scriptureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          // TODO(milestone-4): wire to the bookmark repository.
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_border_rounded),
            tooltip: AppStrings.scriptureSave,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.ios_share_rounded),
            tooltip: AppStrings.scriptureShare,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.stackLg,
          ),
          children: [
            Center(child: SectionLabel('Psalm 23')),
            const SizedBox(height: AppSpacing.stackSm),
            Center(
              child: Text(
                AppConstants.defaultTranslation,
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // TODO(milestone-2): render the chapter verse by verse so each
            // verse can be selected, highlighted, and shared individually.
            Text(
              'The Lord is my shepherd; I shall not want.',
              style: AppTypography.bodyLg.copyWith(
                color: context.colors.onSurface,
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            FilledButton(
              onPressed: () => context.pushNamed(
                AppRoute.reflection.name,
                queryParameters: {'scriptureId': scriptureId},
              ),
              child: const Text(AppStrings.scriptureReflectAction),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.scriptureRelatedLabel),
            const SizedBox(height: AppSpacing.stackMd),
            // TODO(milestone-2): related passages from semantic search.
            const ScriptureCard(
              reference: 'Psalm 23:2',
              text: 'He maketh me to lie down in green pastures: he leadeth me '
                  'beside the still waters.',
              translation: AppConstants.defaultTranslation,
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}
