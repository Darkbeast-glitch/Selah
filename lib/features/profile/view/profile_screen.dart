import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_shell.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/widgets/section_label.dart';

/// Profile — your journey, preferences, and account (PRD §19).
///
/// Design: `selah_scripture_companion/profile_settings/`.
///
/// Structural scaffold: appearance is fully wired (it is device-local), while
/// the journey counts, translation picker, notifications, and data deletion
/// await their repositories.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
            Text(AppConstants.appName, style: context.text.headlineLarge),
            const SizedBox(height: AppSpacing.stackSm),
            Text(AppConstants.tagline, style: context.text.bodySmall),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.profileJourneyLabel),
            const SizedBox(height: AppSpacing.stackMd),
            // TODO(milestone-4): live counts from the library repository.
            const _Row(
              icon: Icons.bookmark_border_rounded,
              label: AppStrings.profileSavedScriptures,
            ),
            const _Row(
              icon: Icons.edit_note_rounded,
              label: AppStrings.profileReflections,
            ),
            const _Row(
              icon: Icons.self_improvement_outlined,
              label: AppStrings.profilePrayers,
            ),
            const _Row(
              icon: Icons.forum_outlined,
              label: AppStrings.profileConversationHistory,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.profilePreferencesLabel),
            const SizedBox(height: AppSpacing.stackMd),
            // TODO(milestone-2): translation picker, once more than one
            // licensed translation is available (PRD §12).
            _Row(
              icon: Icons.menu_book_outlined,
              label: AppStrings.profileTranslation,
              trailing: Text(
                AppConstants.defaultTranslation,
                style: context.text.bodySmall,
              ),
            ),
            _AppearanceRow(themeMode: themeMode),
            const _Row(
              icon: Icons.notifications_none_rounded,
              label: AppStrings.profileNotifications,
            ),
            const _Row(
              icon: Icons.language_rounded,
              label: AppStrings.profileLanguage,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.profileAboutLabel),
            const SizedBox(height: AppSpacing.stackMd),
            const _Row(
              icon: Icons.info_outline_rounded,
              label: AppStrings.profileAboutSelah,
            ),
            const _Row(
              icon: Icons.lock_outline_rounded,
              label: AppStrings.profilePrivacy,
            ),
            const _Row(
              icon: Icons.description_outlined,
              label: AppStrings.profileTerms,
            ),
            const _Row(
              icon: Icons.auto_stories_outlined,
              label: AppStrings.profileScriptureSources,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.profileAccountLabel),
            const SizedBox(height: AppSpacing.stackMd),
            // TODO(milestone-5): PRD §36 requires working data deletion.
            _Row(
              icon: Icons.delete_outline_rounded,
              label: AppStrings.profileDeleteData,
              color: context.colors.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    this.trailing,
    this.color,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // TODO(milestone-4): each row navigates once its destination exists.
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? context.colors.onSurfaceVariant),
      title: Text(
        label,
        style: context.text.bodyMedium?.copyWith(color: color),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right_rounded,
            color: context.colors.outlineVariant,
          ),
    );
  }
}

/// Appearance is device-local, so it works today without any backend.
class _AppearanceRow extends ConsumerWidget {
  const _AppearanceRow({required this.themeMode});

  final ThemeMode themeMode;

  static const _labels = {
    ThemeMode.system: 'System',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Row(
      icon: Icons.dark_mode_outlined,
      label: AppStrings.profileAppearance,
      trailing: DropdownButton<ThemeMode>(
        value: themeMode,
        underline: const SizedBox.shrink(),
        borderRadius: AppRadius.cardRadius,
        style: context.text.bodyMedium,
        items: [
          for (final entry in _labels.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: (mode) {
          if (mode != null) {
            ref.read(themeModeProvider.notifier).setMode(mode);
          }
        },
      ),
    );
  }
}
