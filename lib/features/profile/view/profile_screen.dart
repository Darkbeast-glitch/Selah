import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_shell.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_info_text.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/widgets/section_label.dart';
import '../../conversation/data/conversation_repository.dart';
import '../../library/data/library_repository.dart';
import '../data/data_deletion_service.dart';
import 'widgets/info_sheet.dart';

/// Profile — your journey, preferences, and account (PRD §19).
///
/// Design: `selah_scripture_companion/profile_settings/`.
///
/// **Every row here responds to a tap.** A settings list where half the rows do
/// nothing reads as a broken app, so anything not yet implemented says so
/// explicitly rather than staying silent — see [_unavailable].
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  /// Deep-links into a Library tab. Indexes match `LibraryScreen`'s TabBar.
  void _openLibrary(BuildContext context, int tab) => context.goNamed(
    AppRoute.library.name,
    queryParameters: {'tab': '$tab'},
  );

  /// Honest response for a row whose feature isn't built yet.
  ///
  /// Deliberately explains *why* rather than saying "coming soon": a user who
  /// knows only one translation is licensed understands the app, whereas
  /// "coming soon" just reads as unfinished.
  void _unavailable(BuildContext context, String message) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );

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
            _CountRow(
              icon: Icons.bookmark_border_rounded,
              label: AppStrings.profileSavedScriptures,
              count: ref.watch(bookmarksProvider).value?.length,
              onTap: () => _openLibrary(context, 0),
            ),
            _CountRow(
              icon: Icons.forum_outlined,
              label: AppStrings.profileConversationHistory,
              count: ref.watch(conversationsProvider).value?.length,
              onTap: () => _openLibrary(context, 1),
            ),
            _CountRow(
              icon: Icons.edit_note_rounded,
              label: AppStrings.profileReflections,
              count: ref.watch(reflectionsProvider).value?.length,
              onTap: () => _openLibrary(context, 2),
            ),
            _CountRow(
              icon: Icons.self_improvement_outlined,
              label: AppStrings.profilePrayers,
              count: ref.watch(prayersProvider).value?.length,
              onTap: () => _openLibrary(context, 3),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.profilePreferencesLabel),
            const SizedBox(height: AppSpacing.stackMd),
            _Row(
              icon: Icons.menu_book_outlined,
              label: AppStrings.profileTranslation,
              trailing: Text(
                AppConstants.defaultTranslation,
                style: context.text.bodySmall,
              ),
              onTap: () => InfoSheet.show(
                context,
                title: AppStrings.profileTranslation,
                body: AppInfoText.scriptureSources,
              ),
            ),
            _AppearanceRow(themeMode: themeMode),
            _Row(
              icon: Icons.notifications_none_rounded,
              label: AppStrings.profileNotifications,
              onTap: () => _unavailable(
                context,
                'Daily reminders are not available yet. When they arrive they '
                'will be optional, gentle, and never about streaks.',
              ),
            ),
            _Row(
              icon: Icons.language_rounded,
              label: AppStrings.profileLanguage,
              trailing: Text('English', style: context.text.bodySmall),
              onTap: () => _unavailable(
                context,
                'Selah is available in English for now.',
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.profileAboutLabel),
            const SizedBox(height: AppSpacing.stackMd),
            _Row(
              icon: Icons.info_outline_rounded,
              label: AppStrings.profileAboutSelah,
              onTap: () => InfoSheet.show(
                context,
                title: AppStrings.profileAboutSelah,
                body: AppInfoText.aboutSelah,
              ),
            ),
            _Row(
              icon: Icons.lock_outline_rounded,
              label: AppStrings.profilePrivacy,
              onTap: () => InfoSheet.show(
                context,
                title: AppStrings.profilePrivacy,
                body: AppInfoText.privacy,
              ),
            ),
            _Row(
              icon: Icons.description_outlined,
              label: AppStrings.profileTerms,
              onTap: () => InfoSheet.show(
                context,
                title: AppStrings.profileTerms,
                body: AppInfoText.terms,
              ),
            ),
            _Row(
              icon: Icons.auto_stories_outlined,
              label: AppStrings.profileScriptureSources,
              onTap: () => InfoSheet.show(
                context,
                title: AppStrings.profileScriptureSources,
                body: AppInfoText.scriptureSources,
              ),
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            SectionLabel(AppStrings.profileAccountLabel),
            const SizedBox(height: AppSpacing.stackMd),
            const _DeleteDataRow(),
          ],
        ),
      ),
    );
  }
}

/// A journey row with a live count.
///
/// Shows nothing rather than "0" while the stream connects, so the number never
/// flickers 0 → real value.
class _CountRow extends StatelessWidget {
  const _CountRow({
    required this.icon,
    required this.label,
    required this.count,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _Row(
      icon: icon,
      label: label,
      onTap: onTap,
      // MainAxisSize.min is required, not cosmetic: a Row in ListTile.trailing
      // defaults to max and claims the entire tile width, which makes the tile
      // fail layout outright ("Trailing widget consumes the entire tile width").
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count != null) Text('$count', style: context.text.bodyMedium),
          const SizedBox(width: AppSpacing.stackSm),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colors.outlineVariant,
          ),
        ],
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
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

/// Appearance is device-local, so it works with no network and no account.
///
/// A tappable row opening a chooser rather than an inline `DropdownButton`: the
/// dropdown was a small target inside a row that otherwise did nothing, so
/// tapping the label — the obvious thing to tap — had no effect.
class _AppearanceRow extends ConsumerWidget {
  const _AppearanceRow({required this.themeMode});

  final ThemeMode themeMode;

  static const _labels = {
    ThemeMode.system: 'System',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
  };

  Future<void> _choose(BuildContext context, WidgetRef ref) async {
    final chosen = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.containerMargin,
              ),
              child: Text(
                AppStrings.profileAppearance,
                style: context.text.headlineMedium,
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            for (final entry in _labels.entries)
              ListTile(
                title: Text(entry.value),
                trailing: entry.key == themeMode
                    ? Icon(Icons.check_rounded, color: context.colors.primary)
                    : null,
                onTap: () => Navigator.pop(context, entry.key),
              ),
            const SizedBox(height: AppSpacing.stackMd),
          ],
        ),
      ),
    );

    if (chosen != null) {
      await ref.read(themeModeProvider.notifier).setMode(chosen);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Row(
      icon: Icons.dark_mode_outlined,
      label: AppStrings.profileAppearance,
      onTap: () => _choose(context, ref),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_labels[themeMode]!, style: context.text.bodySmall),
          const SizedBox(width: AppSpacing.stackSm),
          Icon(
            Icons.chevron_right_rounded,
            color: context.colors.outlineVariant,
          ),
        ],
      ),
    );
  }
}

/// "Delete my data" (PRD §36).
///
/// Two-step confirmation, because this is irreversible and destroys personal
/// writing. The second step spells out exactly what goes, by name — a vague
/// "are you sure?" is not informed consent for deleting someone's reflections.
class _DeleteDataRow extends ConsumerStatefulWidget {
  const _DeleteDataRow();

  @override
  ConsumerState<_DeleteDataRow> createState() => _DeleteDataRowState();
}

class _DeleteDataRowState extends ConsumerState<_DeleteDataRow> {
  bool _isDeleting = false;

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete everything?'),
        content: const Text(
          'This permanently deletes your saved Scriptures, reflections, '
          'prayers, and conversations, along with your anonymous account.\n\n'
          'Selah will still work afterwards — it will simply be empty. This '
          'cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.error,
            ),
            child: const Text('Delete everything'),
          ),
        ],
      ),
    );
    if (!(confirmed ?? false) || !mounted) return;

    setState(() => _isDeleting = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(dataDeletionServiceProvider).deleteEverything();
      if (!mounted) return;

      // The streams are bound to the old uid; refresh so the UI reflects the
      // new, empty session rather than showing stale counts.
      ref.invalidate(libraryRepositoryProvider);
      ref.invalidate(conversationRepositoryProvider);

      messenger.showSnackBar(
        const SnackBar(content: Text('Your data has been deleted.')),
      );
    } on AppException catch (error) {
      // The account is deliberately left intact on failure so a retry is
      // possible — see DataDeletionService.
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Row(
      icon: Icons.delete_outline_rounded,
      label: AppStrings.profileDeleteData,
      color: context.colors.error,
      onTap: _isDeleting ? null : _confirmAndDelete,
      trailing: _isDeleting
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.error,
              ),
            )
          : Icon(
              Icons.chevron_right_rounded,
              color: context.colors.outlineVariant,
            ),
    );
  }
}
