import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// The small uppercase eyebrow that opens each section — "SCRIPTURE",
/// "WHY THIS PASSAGE", "REFLECT", "TODAY'S SCRIPTURE".
///
/// This is how the conversation reads as an edited page rather than a chat log
/// (PRD §10). Uses the `label-caps` token in forest green.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: context.text.labelSmall?.copyWith(
        color: color ?? context.colors.primary,
      ),
    );
  }
}

/// A thin, elegant divider used to separate the sections of an AI response.
/// Deliberately not a chat-bubble boundary.
class SectionDivider extends StatelessWidget {
  const SectionDivider({super.key, this.height = AppSpacing.sectionGap});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Divider(color: context.colors.outlineVariant, thickness: 0.5),
      ),
    );
  }
}

/// The subtle gold ornament that sits above Scripture text on a Scripture card
/// (DESIGN.md → Components → Scripture Card).
class ScriptureOrnament extends StatelessWidget {
  const ScriptureOrnament({super.key, this.width = 32});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1.5,
      decoration: BoxDecoration(
        color: context.selahColors.tertiaryFixedDim,
        borderRadius: AppRadius.pill,
      ),
    );
  }
}
