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

/// Home — the front door (PRD §9).
///
/// Design: `selah_scripture_companion/home/`. The one job of this screen is to
/// make it easy to say what you're carrying, so the prompt and input sit above
/// everything else.
///
/// Structural scaffold: Today's Scripture is placeholder content until the
/// Scripture corpus lands in Milestone 2, and sending a message currently just
/// opens the conversation route. A `HomeViewModel` will supply the greeting,
/// verse of the day, and send action.
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
            // TODO(milestone-2): replace with the verse of the day from the
            // Scripture repository.
            const ScriptureCard(
              reference: 'Psalm 23:1',
              text: 'The Lord is my shepherd; I shall not want.',
              translation: AppConstants.defaultTranslation,
            ),

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
