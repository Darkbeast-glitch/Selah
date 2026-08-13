import 'package:flutter/material.dart';

import '../../../../app/app_theme.dart';

/// A scrollable prose sheet for the Profile screen's informational rows.
///
/// A bottom sheet rather than a pushed route: these are short reference reads,
/// not destinations, and a sheet keeps Profile in view behind them.
class InfoSheet extends StatelessWidget {
  const InfoSheet({super.key, required this.title, required this.body});

  final String title;

  /// Plain paragraphs. A leading `#` marks a subheading.
  final String body;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String body,
  }) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => InfoSheet(title: title, body: body),
      );

  @override
  Widget build(BuildContext context) {
    final blocks = body
        .split('\n\n')
        .map((block) => block.trim())
        .where((block) => block.isNotEmpty);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.containerMargin,
          0,
          AppSpacing.containerMargin,
          AppSpacing.sectionGap,
        ),
        children: [
          Text(title, style: context.text.headlineLarge),
          const SizedBox(height: AppSpacing.stackLg),
          for (final block in blocks) ...[
            if (block.startsWith('#'))
              Text(
                block.substring(1).trim(),
                style: context.text.headlineMedium,
              )
            else
              Text(block, style: context.text.bodyMedium),
            const SizedBox(height: AppSpacing.stackMd),
          ],
        ],
      ),
    );
  }
}
