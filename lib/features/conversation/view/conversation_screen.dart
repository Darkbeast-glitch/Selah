import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/conversation_input.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../../core/widgets/section_label.dart';

/// The conversation — Selah's primary experience (PRD §8, §10).
///
/// Design: `selah_scripture_companion/conversation/`.
///
/// **This screen must not look like a chat client.** No bubbles. An AI turn is
/// laid out as an edited page — acknowledgement, then SCRIPTURE, then WHY THIS
/// PASSAGE, then REFLECT — separated by thin dividers, with the user's own words
/// set apart on a tonal surface. The structure below mirrors the response
/// contract in PRD §26 and is rendered section by section, never as one blob.
///
/// Structural scaffold: the turn shown is static example content. Milestone 3
/// replaces it with a `ConversationViewModel` streaming real responses from the
/// backend RAG pipeline.
class ConversationScreen extends ConsumerWidget {
  const ConversationScreen({
    super.key,
    this.conversationId,
    this.openingMessage,
  });

  /// Null when starting fresh; set when resuming from History.
  final String? conversationId;

  /// The message that opened this conversation, passed from Home.
  final String? openingMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.containerMargin,
                  vertical: AppSpacing.stackLg,
                ),
                children: [
                  if (openingMessage != null) ...[
                    _UserTurn(message: openingMessage!),
                    const SectionDivider(),
                  ],
                  // TODO(milestone-3): render the streamed AiResponse model.
                  const _AiTurn(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.containerMargin,
                0,
                AppSpacing.containerMargin,
                AppSpacing.stackMd,
              ),
              child: ConversationInput(
                hintText: AppStrings.conversationInputHint,
                // TODO(milestone-3): send through the conversation view model.
                onSubmit: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The user's own words. Set apart by a tonal surface rather than a bubble tail,
/// and right-inset so the page still reads top-to-bottom.
class _UserTurn extends StatelessWidget {
  const _UserTurn({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sectionGap),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.stackLg),
        decoration: BoxDecoration(
          color: context.colors.surfaceContainer,
          borderRadius: AppRadius.cardRadius,
        ),
        child: Text(message, style: context.text.bodyMedium),
      ),
    );
  }
}

/// One AI turn, rendered as the four independent sections of PRD §26:
/// acknowledgement → scriptures → explanation → reflectionQuestion.
class _AiTurn extends StatelessWidget {
  const _AiTurn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // acknowledgement
        Text(
          AppStrings.conversationOpening,
          style: context.text.bodyLarge,
        ),

        const SectionDivider(),

        // scriptures
        SectionLabel(AppStrings.conversationScriptureLabel),
        const SizedBox(height: AppSpacing.stackMd),
        const ScriptureCard(
          reference: 'Psalm 23:1',
          text: 'The Lord is my shepherd; I shall not want.',
          translation: AppConstants.defaultTranslation,
        ),

        const SectionDivider(),

        // explanation
        SectionLabel(AppStrings.conversationWhyLabel),
        const SizedBox(height: AppSpacing.stackMd),
        Text(
          'A short, grounded explanation of why this passage speaks to what '
          'the user brought — drawn only from the retrieved context.',
          style: context.text.bodyLarge,
        ),

        const SectionDivider(),

        // reflectionQuestion
        SectionLabel(AppStrings.conversationReflectLabel),
        const SizedBox(height: AppSpacing.stackMd),
        Text(
          'What would trusting God look like in this situation?',
          style: AppTypography.h2.copyWith(color: context.colors.onSurface),
        ),
      ],
    );
  }
}
