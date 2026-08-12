import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_shell.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/conversation_input.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../scripture/data/scripture_repository.dart';

/// Home — the front door (PRD §9).
///
/// Design: `selah_scripture_companion/home/`. The one job of this screen is to
/// make it easy to say what you're carrying, so the prompt and input sit above
/// everything else.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _startConversation(BuildContext context, String message) {
    context.pushNamed(
      AppRoute.conversation.name,
      queryParameters: {'message': message},
    );
  }

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
            Text(
              AppDateUtils.greeting(),
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),

            Text(AppStrings.homePrompt, style: context.text.headlineLarge),
            const SizedBox(height: AppSpacing.stackLg),

            ConversationInput(
              hintText: AppStrings.homeInputHint,
              onSubmit: (message) => _startConversation(context, message),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.homeTopicsLabel),
            const SizedBox(height: AppSpacing.stackMd),
            const _TopicShortcuts(),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.homeTodaysScripture),
            const SizedBox(height: AppSpacing.stackMd),
            const _TodaysScripture(),

            const SizedBox(height: AppSpacing.sectionGap),

            Center(
              child: Text(
                AppStrings.homeReflectPrompt,
                style: context.text.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Today's Scripture, drawn from the curated daily pool.
///
/// Every async state is handled (PRD §38) — the card must never collapse into a
/// blank gap on the app's front door.
class _TodaysScripture extends ConsumerWidget {
  const _TodaysScripture();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = ref.watch(verseOfTheDayProvider);

    return verse.when(
      loading: () => const _CardPlaceholder(),
      error: (_, _) => _CardPlaceholder(
        child: Center(
          child: Text(
            AppStrings.errorTitle,
            style: context.text.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ),
      data: (scripture) {
        if (scripture == null) {
          // The pool id is missing from the corpus — a build-time mistake, not
          // something the user can fix, so show nothing rather than an error.
          return const SizedBox.shrink();
        }
        return ScriptureCard(
          reference: scripture.reference,
          text: scripture.text,
          translation: scripture.translation,
          onOpen: () => context.pushNamed(
            AppRoute.scripture.name,
            pathParameters: {'scriptureId': scripture.id},
          ),
        );
      },
    );
  }
}

/// Reserves the card's height while loading so the page doesn't jump.
class _CardPlaceholder extends StatelessWidget {
  const _CardPlaceholder({this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: context.colors.surfaceContainerLow,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: context.colors.outlineVariant, width: 0.5),
      ),
      child: child,
    );
  }
}

/// The eight topic shortcuts from PRD §9. Tapping one opens a conversation
/// seeded with that topic.
class _TopicShortcuts extends StatelessWidget {
  const _TopicShortcuts();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.stackSm,
      runSpacing: AppSpacing.stackSm,
      children: [
        for (final topic in HomeTopic.values)
          ActionChip(
            label: Text(topic.label),
            onPressed: () => context.pushNamed(
              AppRoute.conversation.name,
              queryParameters: {'message': topic.label},
            ),
          ),
      ],
    );
  }
}
