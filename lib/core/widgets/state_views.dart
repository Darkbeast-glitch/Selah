import 'package:flutter/material.dart';

import '../../app/app_theme.dart';
import '../constants/app_strings.dart';

/// The four async states every screen must be able to render (PRD §38).
///
/// "Never leave the user looking at a blank screen." Whenever a ViewModel
/// exposes an `AsyncValue`, map it onto these — do not invent one-off spinners.
/// Design reference: `selah_scripture_companion/states_feedbacks/`.

/// Level-0 loading state. Quiet and centred, with an optional message such as
/// [AppStrings.loadingScripture].
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.containerMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.stackLg),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.text.headlineMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a retry affordance. Never surfaces a raw exception string —
/// pass the user-safe `AppException.message`.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, this.message, this.onRetry});

  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: Icons.refresh_rounded,
      title: AppStrings.errorTitle,
      body: message,
      action: onRetry == null
          ? null
          : OutlinedButton(
              onPressed: onRetry,
              child: const Text(AppStrings.errorRetry),
            ),
    );
  }
}

/// Empty state. Copy should invite rather than scold — see
/// [AppStrings.emptyLibraryTitle].
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.body,
    this.icon,
    this.action,
  });

  final String title;
  final String? body;
  final IconData? icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return _CenteredState(
      icon: icon ?? Icons.auto_stories_outlined,
      title: title,
      body: body,
      action: action,
    );
  }
}

/// Offline banner. Shown above content that is still readable from cache
/// (PRD §37) rather than replacing the whole screen.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.containerMargin,
        vertical: AppSpacing.stackMd,
      ),
      color: context.colors.secondaryContainer,
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 18,
            color: context.selahColors.onSecondaryFixedVariant,
          ),
          const SizedBox(width: AppSpacing.stackSm),
          Expanded(
            child: Text(
              AppStrings.offlineMessage,
              style: context.text.bodySmall?.copyWith(
                color: context.selahColors.onSecondaryFixedVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.icon,
    required this.title,
    this.body,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sectionGap),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: context.colors.primary, size: 28),
            ),
            const SizedBox(height: AppSpacing.stackLg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: context.text.headlineMedium,
            ),
            if (body != null) ...[
              const SizedBox(height: AppSpacing.stackSm),
              Text(
                body!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.stackLg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
