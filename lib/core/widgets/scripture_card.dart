import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import 'section_label.dart';

/// The app's most important component: a passage of Scripture.
///
/// Per DESIGN.md, a Scripture card is a level-2 surface — lifted, centred, with
/// a gold ornament above the verse, the text set in EB Garamond at maximum
/// hierarchy, and the reference in tracked forest-green caps.
///
/// This widget is intentionally presentational and takes primitives. Once the
/// `Scripture` model lands in `features/scripture/data/models/`, callers should
/// map the model to these fields rather than this widget importing the model —
/// that keeps a shared core widget free of feature dependencies.
class ScriptureCard extends StatelessWidget {
  const ScriptureCard({
    super.key,
    required this.reference,
    required this.text,
    required this.translation,
    this.isSaved = false,
    this.onSave,
    this.onOpen,
    this.compact = false,
  });

  /// Human-readable reference, e.g. "Psalm 23:1".
  final String reference;

  /// The verse text, without surrounding quotation marks.
  final String text;

  /// Translation code, e.g. "KJV".
  final String translation;

  final bool isSaved;
  final VoidCallback? onSave;
  final VoidCallback? onOpen;

  /// Compact cards appear in lists (search results, related passages) and drop
  /// the ornament and the lifted shadow.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final card = Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        compact ? AppSpacing.stackLg : AppSpacing.containerMargin,
      ),
      decoration: BoxDecoration(
        color: compact
            ? colors.surfaceContainerLow
            : colors.surfaceContainerLowest,
        borderRadius: AppRadius.cardRadius,
        border: Border.all(color: colors.outlineVariant, width: compact ? 1 : 0.5),
        boxShadow: compact
            ? null
            : AppElevation.ambient(context.selahColors.ambientShadow),
      ),
      child: Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          if (!compact) ...[
            const ScriptureOrnament(),
            const SizedBox(height: AppSpacing.stackLg),
          ],
          Text(
            text,
            textAlign: compact ? TextAlign.start : TextAlign.center,
            style: compact
                ? context.text.bodyLarge
                : AppTypography.displayScriptureMobile.copyWith(
                    color: colors.onSurface,
                  ),
            maxLines: compact ? 3 : null,
            overflow: compact ? TextOverflow.ellipsis : null,
          ),
          SizedBox(
            height: compact ? AppSpacing.stackSm : AppSpacing.stackLg,
          ),
          Row(
            mainAxisAlignment:
                compact ? MainAxisAlignment.start : MainAxisAlignment.center,
            children: [
              SectionLabel(reference),
              const SizedBox(width: AppSpacing.stackSm),
              Text(
                translation,
                style: context.text.labelSmall?.copyWith(
                  color: colors.outline,
                ),
              ),
            ],
          ),
          if (onSave != null && !compact) ...[
            const SizedBox(height: AppSpacing.stackLg),
            _SaveButton(isSaved: isSaved, onSave: onSave!),
          ],
        ],
      ),
    );

    if (onOpen == null) return card;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.cardRadius,
      child: InkWell(
        onTap: onOpen,
        borderRadius: AppRadius.cardRadius,
        child: card,
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.isSaved, required this.onSave});

  final bool isSaved;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onSave,
      tooltip: isSaved ? 'Saved' : 'Save',
      icon: Icon(
        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        color: isSaved ? context.colors.primary : context.colors.outline,
      ),
    );
  }
}
