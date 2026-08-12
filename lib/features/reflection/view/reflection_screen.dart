import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../library/data/library_repository.dart';
import '../../scripture/data/scripture_repository.dart';

/// Reflection — where a passage becomes personal (PRD §17).
///
/// Design: `selah_scripture_companion/reflection/`. Reflections are private by
/// default and live only under the user's own Firestore subtree, which
/// `firestore.rules` enforces.
class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key, this.scriptureId, this.reflectionId});

  /// The passage being reflected on.
  final String? scriptureId;

  /// Set when reopening a saved reflection.
  final String? reflectionId;

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> {
  final _controller = TextEditingController();

  /// Set once saved, so a second tap updates rather than creating a duplicate.
  String? _savedId;
  bool _isSaving = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _savedId = widget.reflectionId;
    if (_savedId != null) _load(_savedId!);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load(String id) async {
    setState(() => _isLoading = true);
    try {
      final existing = await ref.read(libraryRepositoryProvider).reflection(id);
      if (existing != null && mounted) _controller.text = existing.content;
    } on AppException catch (error) {
      if (mounted) _notify(error.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _notify(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _save() async {
    final content = _controller.text.trim();
    if (content.isEmpty) {
      _notify('Write something first.');
      return;
    }
    final scriptureId = widget.scriptureId;
    if (scriptureId == null) {
      _notify('This reflection is not linked to a passage.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final library = ref.read(libraryRepositoryProvider);
      if (_savedId case final id?) {
        await library.updateReflection(id, content);
      } else {
        _savedId = await library.saveReflection(
          scriptureId: scriptureId,
          content: content,
        );
      }
      if (mounted) _notify('Reflection saved');
    } on AppException catch (error) {
      if (mounted) _notify(error.message);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Saves before leaving, so the prayer is built from kept words rather than a
  /// draft that vanishes.
  Future<void> _toPrayer() async {
    if (_controller.text.trim().isNotEmpty && _savedId == null) await _save();
    if (!mounted) return;
    context.pushNamed(
      AppRoute.prayer.name,
      queryParameters: {
        'reflectionId': ?_savedId,
        'scriptureId': ?widget.scriptureId,
        'seed': _controller.text.trim(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.reflectionTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.stackLg,
          ),
          children: [
            if (widget.scriptureId case final id?) _Passage(scriptureId: id),

            const SizedBox(height: AppSpacing.sectionGap),

            Text(
              AppStrings.reflectionPrompt,
              style: AppTypography.h2.copyWith(color: context.colors.onSurface),
            ),
            const SizedBox(height: AppSpacing.stackMd),

            TextField(
              controller: _controller,
              enabled: !_isLoading,
              minLines: 6,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: context.text.bodyMedium,
              decoration: InputDecoration(
                hintText: _isLoading ? 'Loading…' : AppStrings.reflectionHint,
              ),
            ),
            const SizedBox(height: AppSpacing.stackSm),
            Text(
              AppStrings.reflectionPrivacyNote,
              style: context.text.bodySmall,
            ),

            const SizedBox(height: AppSpacing.sectionGap),

            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: Text(
                _isSaving
                    ? 'Saving…'
                    : _savedId == null
                        ? AppStrings.reflectionSave
                        : 'Update reflection',
              ),
            ),
            const SizedBox(height: AppSpacing.stackMd),
            OutlinedButton(
              onPressed: _isSaving ? null : _toPrayer,
              child: const Text(AppStrings.reflectionToPrayer),
            ),
          ],
        ),
      ),
    );
  }
}

/// The passage being reflected on, loaded from the local corpus.
class _Passage extends ConsumerWidget {
  const _Passage({required this.scriptureId});

  final String scriptureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scripture = ref.watch(scriptureByIdProvider(scriptureId));

    return scripture.maybeWhen(
      data: (verse) => verse == null
          ? const SizedBox.shrink()
          : ScriptureCard(
              reference: verse.reference,
              text: verse.text,
              translation: verse.translation,
            ),
      orElse: () => const SizedBox(height: 120),
    );
  }
}
