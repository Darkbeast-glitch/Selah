import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/section_label.dart';

/// Prayer starter (PRD §18).
///
/// The framing here is a product requirement, not a style choice: this is a
/// *starter* the user is free to edit, and it is labelled
/// [AppStrings.prayerStarterLabel] — never "God's prayer", "God's response", or
/// "what God wants you to pray". The card uses the forest-green prayer surface
/// from DESIGN.md so it reads as the user's own words rather than as Scripture.
///
/// Structural scaffold: the text is placeholder. Milestone 4 generates it from
/// the reflection via the backend and persists it to `users/{uid}/prayers`.
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key, this.reflectionId, this.prayerId});

  /// The reflection this prayer starter grew out of.
  final String? reflectionId;

  /// Set when reopening a saved prayer.
  final String? prayerId;

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  final _controller = TextEditingController(
    text: 'Lord, help me trust You with the things I cannot control...',
  );
  bool _editing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.prayerStarterLabel)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.stackLg,
          ),
          children: [
            _PrayerCard(controller: _controller, editing: _editing),

            const SizedBox(height: AppSpacing.sectionGap),

            // TODO(milestone-4): persist via the prayer repository.
            FilledButton(
              onPressed: () {},
              child: const Text(AppStrings.prayerSave),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            OutlinedButton(
              onPressed: () => setState(() => _editing = !_editing),
              child: Text(_editing ? 'Done' : AppStrings.prayerEdit),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            // TODO(milestone-4): regenerate from the source reflection.
            TextButton(
              onPressed: () {},
              child: const Text(AppStrings.prayerRegenerate),
            ),
          ],
        ),
      ),
    );
  }
}

/// DESIGN.md → Prayer & Reflection Cards: a light forest-green surface with
/// ivory text, visually distinct from a Scripture card so "God's Word" and
/// "my prayer" are never confused.
class _PrayerCard extends StatelessWidget {
  const _PrayerCard({required this.controller, required this.editing});

  final TextEditingController controller;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    final selah = context.selahColors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.containerMargin),
      decoration: BoxDecoration(
        color: context.colors.primaryContainer,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            AppStrings.prayerStarterLabel,
            color: selah.primaryFixedDim,
          ),
          const SizedBox(height: AppSpacing.stackMd),
          if (editing)
            TextField(
              controller: controller,
              minLines: 4,
              maxLines: null,
              autofocus: true,
              style: AppTypography.bodyLg.copyWith(
                color: context.colors.onPrimaryContainer,
              ),
              cursorColor: selah.primaryFixed,
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            )
          else
            Text(
              controller.text,
              style: AppTypography.bodyLg.copyWith(
                color: context.colors.onPrimaryContainer,
              ),
            ),
        ],
      ),
    );
  }
}
