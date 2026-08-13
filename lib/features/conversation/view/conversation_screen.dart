import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/conversation_input.dart';
import '../../../core/widgets/safety_notice.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/state_views.dart';
import '../../scripture/data/models/scripture.dart';
import '../../scripture/data/scripture_repository.dart';
import '../../scripture/data/topic_catalog.dart';
import '../data/conversation_repository.dart';
import '../data/models/ai_models.dart';
import '../data/models/conversation_models.dart';
import '../viewmodel/conversation_controller.dart';

/// The conversation — Selah's primary experience (PRD §8, §10).
///
/// Design: `selah_scripture_companion/conversation/`.
///
/// **This screen must not look like a chat client.** No bubbles. Each turn is
/// laid out as an edited page, separated by thin dividers, with the user's own
/// words set apart on a tonal surface.
///
/// A turn renders: crisis notice (if any) → the reply's opening → SCRIPTURE →
/// CONSIDER THIS (the substance) → REFLECT. With no backend reachable, the
/// passages still render and the prose sections are simply absent — never filled
/// with placeholder text, since inventing commentary is what §24 forbids.
///
/// Turn state lives in [ConversationController], not here, because each request
/// must carry the prior exchange. Sending messages in isolation is why follow-up
/// questions used to get a fresh topic lookup instead of an answer.
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
  /// Null until the first message creates the thread.
  String? _conversationId;

  final _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;

    // The controller is not family-scoped, so a freshly opened screen must
    // start from empty rather than inherit the previous conversation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(conversationControllerProvider.notifier);
      controller.reset();

      if (widget.conversationId != null) {
        _restore(widget.conversationId!);
      } else if (widget.openingMessage?.trim().isNotEmpty ?? false) {
        _send(widget.openingMessage!.trim());
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _restore(String conversationId) async {
    setState(() => _isLoading = true);
    try {
      final stored = await ref
          .read(conversationRepositoryProvider)
          .messages(conversationId);
      if (!mounted) return;
      await ref.read(conversationControllerProvider.notifier).restore(
            stored
                .where((m) => m.role == MessageRole.user)
                .map((m) => m.content)
                .toList(),
          );
    } on AppException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(error.message)));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Writes the message to Firestore. Failure is non-fatal: the turn stays on
  /// screen and its Scripture still resolves from the local corpus, because
  /// losing history is a smaller harm than losing the passage in front of you.
  Future<void> _persist(String message) async {
    try {
      final id = await ref.read(conversationRepositoryProvider).recordMessage(
            conversationId: _conversationId,
            content: message,
          );
      if (mounted) _conversationId ??= id;
    } on AppException catch (error) {
      debugPrint('[conversation] not saved: ${error.message}');
    }
  }

  void _send(String message) {
    // The controller carries prior turns into the request; the previous
    // per-message provider could not, which is why follow-ups had no context.
    ref.read(conversationControllerProvider.notifier).send(message);
    _persist(message);

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
    final turns = ref.watch(conversationControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const LoadingView()
                  : turns.isEmpty
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
                      itemCount: turns.length,
                      itemBuilder: (context, index) => _Turn(
                        state: turns[index],
                        index: index,
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
  const _Turn({
    required this.state,
    required this.index,
    required this.isFirst,
  });

  final TurnState state;
  final int index;
  final bool isFirst;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = state.message;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isFirst) const SectionDivider(),
        _UserTurn(message: message),
        const SizedBox(height: AppSpacing.sectionGap),

        state.turn.when(
          loading: () => const LoadingView(message: AppStrings.loadingScripture),

          // The backend failed but retrieval may not have. Fall back to the
          // passages alone rather than losing them — the Scripture is the
          // point, the commentary is the addition (§37).
          error: (error, _) => _FailedTurn(
            message: message,
            error: error,
            onRetry: () =>
                ref.read(conversationControllerProvider.notifier).retry(index),
          ),

          data: (turn) => turn.passages.isEmpty
              ? _NoPassages(message: message)
              : _Passages(
                  message: message,
                  scriptures: turn.passages,
                  reflection: turn.reflection,
                ),
        ),

        const SizedBox(height: AppSpacing.stackLg),
      ],
    );
  }
}

/// The backend was unreachable or rejected its own response.
///
/// Retrieval is local, so we still show the passages — the user came for
/// Scripture, and losing it because a network call failed would be the wrong
/// trade. The reason is stated plainly rather than hidden.
class _FailedTurn extends ConsumerWidget {
  const _FailedTurn({
    required this.message,
    required this.error,
    required this.onRetry,
  });

  final String message;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passages = ref.watch(passagesForProvider(message));
    final reason = error is AppException
        ? (error as AppException).message
        : 'Selah could not respond just now.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        passages.maybeWhen(
          data: (scriptures) => scriptures.isEmpty
              ? _NoPassages(message: message)
              : _Passages(message: message, scriptures: scriptures, reflection: null),
          orElse: () => const LoadingView(),
        ),
        const SizedBox(height: AppSpacing.stackLg),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.stackMd),
          decoration: BoxDecoration(
            color: context.colors.surfaceContainer,
            borderRadius: AppRadius.cardRadius,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reason, style: context.text.bodySmall),
              const SizedBox(height: AppSpacing.stackSm),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                ),
                child: const Text(AppStrings.errorRetry),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Passages extends StatelessWidget {
  const _Passages({
    required this.message,
    required this.scriptures,
    required this.reflection,
  });

  final String message;
  final List<Scripture> scriptures;

  /// Null when the backend is unconfigured, unreachable, or out of quota. The
  /// passages still render; only the commentary is absent.
  final AiReflection? reflection;

  /// Per-passage reason, when the backend supplied one for this verse.
  String? _reasonFor(String id) => reflection?.scriptures
      .where((note) => note.id == id)
      .map((note) => note.reason)
      .firstOrNull;

  @override
  Widget build(BuildContext context) {
    final isTopic = TopicCatalog.isTopic(message);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PRD §25: shown before anything else when present, because someone in
        // crisis should not have to read past a reflection to find it.
        if (reflection?.safetyNotice case final notice?) ...[
          SafetyNotice(notice: notice),
          const SizedBox(height: AppSpacing.stackLg),
        ],

        // Honest framing: Scripture speaks about this, rather than any claim
        // that Selah (or God through Selah) is answering (PRD §2). The
        // backend's own acknowledgement is used when we have one.
        Text(
          reflection?.acknowledgement
              ?? (isTopic
                  ? 'Scripture speaks about ${message.toLowerCase()} in many places.'
                  : AppStrings.conversationOpening),
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
          if (_reasonFor(scripture.id) case final reason?) ...[
            const SizedBox(height: AppSpacing.stackSm),
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.stackMd),
              child: Text(
                reason,
                style: context.text.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.stackMd),
        ],

        // The substance of the reply — answers what was asked and teaches
        // something. Absent rather than filled with placeholder prose when
        // there's no backend, because inventing it is what §24 forbids.
        //
        // Labelled "Consider this" after the design reference
        // (`selah_scripture_companion/conversation/`), which anticipated a real
        // prose section here rather than only passage annotations.
        if (reflection?.response case final response?) ...[
          const SectionDivider(),
          SectionLabel(AppStrings.conversationConsiderLabel),
          const SizedBox(height: AppSpacing.stackMd),
          Text(response, style: context.text.bodyLarge),
        ],

        const SectionDivider(),

        SectionLabel(AppStrings.conversationReflectLabel),
        const SizedBox(height: AppSpacing.stackMd),
        Text(
          reflection?.reflectionQuestion ?? AppStrings.reflectionPrompt,
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

        if (reflection?.followUpPrompt case final prompt?) ...[
          const SizedBox(height: AppSpacing.stackLg),
          Text(
            prompt,
            style: context.text.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
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
