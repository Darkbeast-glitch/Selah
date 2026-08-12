import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/widgets/section_label.dart';

/// First-launch introduction.
///
/// Design: `selah_scripture_companion/onboarding/`. Three lines of copy, an
/// honest statement of what Selah is (PRD §2), and a single way forward. There
/// is no sign-up step — authentication happens silently (PRD §20).
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  Future<void> _begin(BuildContext context, WidgetRef ref) async {
    await ref
        .read(preferencesServiceProvider)
        .setOnboardingComplete(value: true);
    if (context.mounted) context.goNamed(AppRoute.home.name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.containerMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              const ScriptureOrnament(width: 48),
              const SizedBox(height: AppSpacing.sectionGap),

              Text(
                AppStrings.onboardingPause,
                textAlign: TextAlign.center,
                style: AppTypography.displayScripture.copyWith(
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: AppSpacing.stackMd),
              Text(
                AppStrings.onboardingBringQuestions,
                textAlign: TextAlign.center,
                style: AppTypography.displayScriptureMobile.copyWith(
                  color: context.colors.primary,
                ),
              ),
              Text(
                AppStrings.onboardingReturnToWord,
                textAlign: TextAlign.center,
                style: AppTypography.displayScriptureMobile.copyWith(
                  color: context.colors.primary,
                ),
              ),

              const Spacer(flex: 2),

              Text(
                AppStrings.aiDisclosure,
                textAlign: TextAlign.center,
                style: context.text.bodySmall,
              ),
              const SizedBox(height: AppSpacing.stackLg),
              FilledButton(
                onPressed: () => _begin(context, ref),
                child: const Text(AppStrings.onboardingBegin),
              ),
              const SizedBox(height: AppSpacing.stackSm),
            ],
          ),
        ),
      ),
    );
  }
}
