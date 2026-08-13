import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

/// Crisis support text (PRD §25).
///
/// The backend computes this from the **user's own message**, independently of
/// what the model produced, so a bad generation cannot suppress it. When the
/// backend sends one, the app is obliged to show it.
///
/// Deliberately not dismissible, not collapsible, and placed above the content
/// it accompanies: this is the one piece of copy in Selah that must not be easy
/// to skip past. It uses the error container rather than the calm ivory palette
/// for the same reason — it should interrupt the app's unhurried rhythm.
class SafetyNotice extends StatelessWidget {
  const SafetyNotice({super.key, required this.notice});

  final String notice;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.stackLg),
      decoration: BoxDecoration(
        color: context.colors.errorContainer,
        borderRadius: AppRadius.cardRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.favorite_outline_rounded,
            size: 20,
            color: context.colors.onErrorContainer,
          ),
          const SizedBox(width: AppSpacing.stackMd),
          Expanded(
            child: Text(
              notice,
              style: context.text.bodyMedium?.copyWith(
                color: context.colors.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
