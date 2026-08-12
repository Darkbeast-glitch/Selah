import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/conversation_input.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/state_views.dart';
import '../../scripture/data/models/scripture.dart';
import '../../scripture/data/scripture_repository.dart';
import '../../scripture/data/topic_catalog.dart';

/// The conversation — Selah's primary experience (PRD §8, §10).
///
/// Design: `selah_scripture_companion/conversation/`.
///
/// **This screen must not look like a chat client.** No bubbles. Each turn is
/// laid out as an edited page, separated by thin dividers, with the user's own
/// words set apart on a tonal surface.
///
/// Scope today: real Scripture retrieval with **no AI interpretation**. A turn
/// shows the passages Scripture offers on the theme plus a reflection prompt.
/// The "WHY THIS PASSAGE" section from PRD §10 is deliberately absent rather
/// than filled with placeholder prose — explaining a passage is interpretation,
/// and inventing it here would be exactly the fabrication PRD §24 forbids.
/// Milestone 3 adds the grounded explanation from the backend.
class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({
    super.key,
    this.conversationId,
    this.openingMessage,
  });

  /// Null when starting fresh; set when resuming from History.
  final String? conversationId;

  /// The message or topic that opened this conversation.
  final String? openingMessage;

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  /// One entry per user message, oldest first.
  late final List<String> _messages = [
    if (widget.openingMessage case final opening?
        when opening.trim().isNotEmpty)
      opening.trim(),
  ];

  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _send(String message) {
    setState(() => _messages.add(message));
    // Let the new turn lay out, then bring it into view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppMotion.normal,
        curve: AppMotion.curve,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const EmptyView(
                      title: AppStrings.homePrompt,
                      body: 'Share what you are carrying, or choose a topic, '
                          'and Selah will point you to Scripture.',
                      icon: Icons.auto_stories_outlined,
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.containerMargin,
                        vertical: AppSpacing.stackLg,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => _Turn(
                        message: _messages[index],
                        isFirst: index == 0,
                      ),
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
                onSubmit: _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One exchange: what the user said, and the Scripture it points to.
class _Turn extends ConsumerWidget {
  const _Turn({required this.message, required this.isFirst});

  final String message;
  final bool isFirst;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passages = ref.watch(passagesForProvider(message));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFirst) const SectionDivider(),
        _UserTurn(message: message),
        const SizedBox(height: AppSpacing.sectionGap),

        passages.when(
          loading: () => const LoadingView(
            message: AppStrings.loadingScripture,
          ),
          error: (error, _) => ErrorView(
            message: '$error',
            onRetry: () => ref.invalidate(passagesForProvider(message)),
          ),
          data: (scriptures) => scriptures.isEmpty
              ? _NoPassages(message: message)
              : _Passages(message: message, scriptures: scriptures),
        ),

        const SizedBox(height: AppSpacing.stackLg),
      ],
    );
  }
}

class _Passages extends StatelessWidget {
  const _Passages({required this.message, required this.scriptures});

  final String message;
  final List<Scripture> scriptures;

  @override
  Widget build(BuildContext context) {
    final isTopic = TopicCatalog.isTopic(message);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Honest framing: Scripture speaks about this, rather than any claim
        // that Selah (or God through Selah) is answering (PRD §2).
        Text(
          isTopic
              ? 'Scripture speaks about ${message.toLowerCase()} in many places.'
              : AppStrings.conversationOpening,
          style: context.text.bodyLarge,
        ),

        const SectionDivider(),

        SectionLabel(AppStrings.conversationScriptureLabel),
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

        const SectionDivider(),

        SectionLabel(AppStrings.conversationReflectLabel),
        const SizedBox(height: AppSpacing.stackMd),
        Text(
          AppStrings.reflectionPrompt,
          style: AppTypography.h2.copyWith(color: context.colors.onSurface),
        ),
        const SizedBox(height: AppSpacing.stackMd),
        OutlinedButton(
          onPressed: () => context.pushNamed(
            AppRoute.reflection.name,
            queryParameters: {'scriptureId': scriptures.first.id},
          ),
          child: const Text(AppStrings.scriptureReflectAction),
        ),
      ],
    );
  }
}

/// Nothing matched. Says so plainly instead of offering an unrelated passage.
class _NoPassages extends StatelessWidget {
  const _NoPassages({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selah could not find a passage for this yet.',
          style: context.text.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.stackSm),
        Text(
          'Try a single word — fear, hope, forgiveness — or search Scripture '
          'directly from Explore.',
          style: context.text.bodyMedium?.copyWith(
            color: context.colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// The user's own words. Set apart by a tonal surface rather than a bubble tail,
/// and left-inset so the page still reads top-to-bottom.
class _UserTurn extends StatelessWidget {
  const _UserTurn({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.sectionGap),
      child: Container(
        width: double.infinity,
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
