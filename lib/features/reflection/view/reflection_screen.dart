import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../scripture/data/scripture_repository.dart';

/// Reflection — where a passage becomes personal (PRD §17).
///
/// Design: `selah_scripture_companion/reflection/`. Reflections are private by
/// default and never leave the user's own Firestore subtree.
///
/// Structural scaffold: the editor is local-only. Milestone 4 adds a
/// `ReflectionViewModel` that persists to `users/{uid}/reflections`.
class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key, this.scriptureId, this.reflectionId});

  /// The passage being reflected on.
  final String? scriptureId;

  /// Set when reopening a saved reflection.
  final String? reflectionId;

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reflectionTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.stackLg,
          ),
          children: [
            if (widget.scriptureId case final id?) _Passage(scriptureId: id),

            const SizedBox(height: AppSpacing.sectionGap),

            Text(
              AppStrings.reflectionPrompt,
              style: AppTypography.h2.copyWith(color: context.colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.stackMd),

            TextField(
              controller: _controller,
              minLines: 6,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: context.text.bodyMedium,
              decoration: const InputDecoration(
                hintText: AppStrings.reflectionHint,
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            Text(
              AppStrings.reflectionPrivacyNote,
              style: context.text.bodySmall,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            // TODO(milestone-4): persist via the reflection repository.
            FilledButton(
              onPressed: () {},
              child: const Text(AppStrings.reflectionSave),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            OutlinedButton(
              onPressed: () => context.pushNamed(
                AppRoute.prayer.name,
                queryParameters: {
                  if (widget.reflectionId != null)
                    'reflectionId': widget.reflectionId!,
                },
              ),
              child: const Text(AppStrings.reflectionToPrayer),
            ),
          ],
        ),
      ),
    );
  }
}

/// The passage being reflected on, loaded from the corpus.
class _Passage extends ConsumerWidget {
  const _Passage({required this.scriptureId});

  final String scriptureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripture = ref.watch(scriptureByIdProvider(scriptureId));

    return scripture.maybeWhen(
      data: (verse) => verse == null
          ? const SizedBox.shrink()
          : ScriptureCard(
              reference: verse.reference,
              text: verse.text,
              translation: verse.translation,
            ),
      orElse: () => const SizedBox(height: 120),
    );
  }
}
