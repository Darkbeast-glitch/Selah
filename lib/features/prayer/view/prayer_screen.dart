import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/section_label.dart';
import '../../library/data/library_repository.dart';

/// Prayer starter (PRD §18).
///
/// The framing here is a product requirement, not a style choice: this is a
/// *starter* the user owns and edits, labelled [AppStrings.prayerStarterLabel] —
/// never "God's prayer", "God's response", or "what God wants you to pray".
///
/// Scope today: the starter is composed from a small set of openings plus the
/// user's own reflection. It is **not** AI-generated, and nothing here claims it
/// is. Milestone 3 replaces the composition with a backend call; the labelling
/// and the user's freedom to edit stay exactly the same.
class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({
    super.key,
    this.reflectionId,
    this.prayerId,
    this.scriptureId,
    this.seed,
  });

  /// The reflection this prayer grew out of.
  final String? reflectionId;

  /// Set when reopening a saved prayer.
  final String? prayerId;

  /// The passage under reflection.
  final String? scriptureId;

  /// The user's reflection text, carried through from the previous screen.
  final String? seed;

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  late final TextEditingController _controller =
      TextEditingController(text: _compose());

  bool _editing = false;
  bool _isSaving = false;
  int _openingIndex = 0;

  /// Openings the app owns. Deliberately generic and non-presumptuous — they
  /// address God without claiming to speak *for* God (PRD §2).
  static const _openings = [
    'Lord, help me trust You with the things I cannot control.',
    'Father, meet me in what I am carrying today.',
    'Lord, teach me what this passage is showing me.',
    'God, give me patience where I want answers.',
    'Father, help me rest in what is true rather than what I fear.',
  ];

  String _compose() {
    final opening = _openings[_openingIndex % _openings.length];
    final reflection = widget.seed?.trim();
    if (reflection == null || reflection.isEmpty) return opening;
    // The user's own words follow the opening — their reflection, not a
    // paraphrase of it, because paraphrasing would be interpretation.
    return '$opening\n\n$reflection';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _notify(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  void _regenerate() {
    setState(() {
      _openingIndex++;
      _controller.text = _compose();
    });
  }

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      _notify('Write something first.');
      return;
    }
    final scriptureId = widget.scriptureId;
    if (scriptureId == null) {
      _notify('This prayer is not linked to a passage.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref
          .read(libraryRepositoryProvider)
          .savePrayer(scriptureId: scriptureId, content: content);
      if (mounted) _notify('Prayer saved');
    } on AppException catch (error) {
      if (mounted) _notify(error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
            _PrayerCard(
              controller: _controller,
              editing: _editing,
              onChanged: () => setState(() {}),
            ),

            const SizedBox(height: AppSpacing.stackMd),
            Text(
              'A starting point in your own words — edit it freely.',
              style: context.text.bodySmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: Text(_isSaving ? 'Saving…' : AppStrings.prayerSave),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            OutlinedButton(
              onPressed: () => setState(() => _editing = !_editing),
              child: Text(_editing ? 'Done' : AppStrings.prayerEdit),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            TextButton(
              onPressed: _regenerate,
              child: const Text(AppStrings.prayerRegenerate),
            ),
          ],
        ),
      ),
    );
  }
}

/// DESIGN.md → Prayer & Reflection Cards: a forest-green surface with ivory
/// text, visually distinct from a Scripture card so "God's Word" and "my prayer"
/// are never confused.
class _PrayerCard extends StatelessWidget {
  const _PrayerCard({
    required this.controller,
    required this.editing,
    required this.onChanged,
  });

  final TextEditingController controller;
  final bool editing;
  final VoidCallback onChanged;

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
              onChanged: (_) => onChanged(),
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
