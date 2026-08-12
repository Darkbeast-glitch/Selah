import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_theme.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_exception.dart';
import '../../library/data/library_repository.dart';
import '../../../core/widgets/scripture_card.dart';
import '../../../core/widgets/section_label.dart';
import '../../../core/widgets/state_views.dart';
import '../data/models/scripture.dart';
import '../data/scripture_repository.dart';

/// The Scripture reader (PRD §15).
///
/// Design: `selah_scripture_companion/scripture_detail/`. A distraction-free
/// reading surface — chrome recedes, the text carries the page.
///
/// The whole chapter is rendered so a verse can be read *in context*, which the
/// PRD asks the app to encourage (§24). The verse you arrived on is highlighted
/// and scrolled to, rather than shown alone.
class ScriptureDetailScreen extends ConsumerWidget {
  const ScriptureDetailScreen({super.key, required this.scriptureId});

  /// Corpus verse id, e.g. `psalms_23_1`.
  final String scriptureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = ref.watch(scriptureByIdProvider(scriptureId));

    return Scaffold(
      appBar: AppBar(
        title: Text(verse.value?.chapterReference ?? ''),
        actions: [
          if (verse.value case final scripture?) ...[
            _BookmarkButton(scriptureId: scripture.id),
            IconButton(
              onPressed: () => _copy(context, scripture),
              icon: const Icon(Icons.copy_rounded),
              tooltip: AppStrings.scriptureCopy,
            ),
          ],
        ],
      ),
      body: verse.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          message: '$error',
          onRetry: () => ref.invalidate(scriptureByIdProvider(scriptureId)),
        ),
        data: (scripture) => scripture == null
            ? const EmptyView(
                title: 'We could not find that passage.',
                body: 'It may have been saved from an older version of Selah.',
                icon: Icons.search_off_rounded,
              )
            : _ChapterView(target: scripture),
      ),
    );
  }

  void _copy(BuildContext context, Scripture scripture) {
    Clipboard.setData(
      ClipboardData(
        text: '"${scripture.text}"\n— ${scripture.reference} '
            '(${scripture.translation})',
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied')),
    );
  }
}

/// Save / unsave this passage.
///
/// Reflects the stored state via a stream, so the icon is driven by Firestore
/// rather than local guesswork — and stays correct across screens and devices.
class _BookmarkButton extends ConsumerWidget {
  const _BookmarkButton({required this.scriptureId});

  final String scriptureId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saved = ref.watch(isBookmarkedProvider(scriptureId));
    final isSaved = saved.value ?? false;

    return IconButton(
      // Disabled while the first value is in flight, so a tap cannot toggle
      // against an unknown state.
      onPressed: saved.hasValue
          ? () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                await ref
                    .read(libraryRepositoryProvider)
                    .toggleBookmark(scriptureId, isSaved: isSaved);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(isSaved ? 'Removed' : AppStrings.scriptureSaved),
                  ),
                );
              } on AppException catch (error) {
                messenger.showSnackBar(
                  SnackBar(content: Text(error.message)),
                );
              }
            }
          : null,
      icon: Icon(
        isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
        color: isSaved ? context.colors.primary : null,
      ),
      tooltip: isSaved ? 'Remove' : AppStrings.scriptureSave,
    );
  }
}

/// Renders the chapter containing [target], scrolling to and highlighting it.
class _ChapterView extends ConsumerStatefulWidget {
  const _ChapterView({required this.target});

  final Scripture target;

  @override
  ConsumerState<_ChapterView> createState() => _ChapterViewState();
}

class _ChapterViewState extends ConsumerState<_ChapterView> {
  final _targetKey = GlobalKey();
  bool _hasScrolled = false;

  /// Brings the arrived-at verse into view once, after the chapter has laid out.
  void _scrollToTarget() {
    if (_hasScrolled) return;
    final targetContext = _targetKey.currentContext;
    if (targetContext == null) return;

    _hasScrolled = true;
    // Verse 1 is already at the top; scrolling would only cause a jolt.
    if (widget.target.verse == 1) return;

    Scrollable.ensureVisible(
      targetContext,
      alignment: 0.3,
      duration: AppMotion.slow,
      curve: AppMotion.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = ref.watch(
      chapterProvider((book: widget.target.book, chapter: widget.target.chapter)),
    );

    return chapter.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: '$error',
        onRetry: () => ref.invalidate(chapterProvider),
      ),
      data: (verses) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToTarget());

        return ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.containerMargin,
            vertical: AppSpacing.stackLg,
          ),
          children: [
            Center(child: SectionLabel(widget.target.chapterReference)),
            const SizedBox(height: AppSpacing.stackSm),
            Center(
              child: Text(
                widget.target.translation,
                style: context.text.labelSmall?.copyWith(
                  color: context.colors.outline,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),

            for (final verse in verses)
              _VerseLine(
                key: verse.id == widget.target.id ? _targetKey : null,
                verse: verse,
                highlighted: verse.id == widget.target.id,
              ),

            const SizedBox(height: AppSpacing.sectionGap),

            FilledButton(
              onPressed: () => context.pushNamed(
                AppRoute.reflection.name,
                queryParameters: {'scriptureId': widget.target.id},
              ),
              child: const Text(AppStrings.scriptureReflectAction),
            ),

            const SizedBox(height: AppSpacing.sectionGap),
            _Context(target: widget.target),
          ],
        );
      },
    );
  }
}

/// One verse: a superscript number and the text, set in the reading face.
///
/// Verses are separate widgets rather than one long string so each can be
/// highlighted, and later selected, shared, and bookmarked individually.
class _VerseLine extends StatelessWidget {
  const _VerseLine({
    super.key,
    required this.verse,
    required this.highlighted,
  });

  final Scripture verse;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.stackMd),
      padding: highlighted
          ? const EdgeInsets.symmetric(
              horizontal: AppSpacing.stackMd,
              vertical: AppSpacing.stackMd,
            )
          : EdgeInsets.zero,
      decoration: highlighted
          ? BoxDecoration(
              color: context.colors.secondaryContainer,
              borderRadius: AppRadius.cardRadius,
            )
          : null,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${verse.verse}  ',
              style: context.text.labelSmall?.copyWith(
                color: context.colors.primary,
              ),
            ),
            TextSpan(
              text: verse.text,
              style: AppTypography.bodyLg.copyWith(
                color: context.colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Surrounding verses.
///
/// Labelled "In context" rather than "Related passages" on purpose: these are
/// adjacent verses, not thematic matches. Calling them related would promise a
/// connection the app cannot currently justify — semantic retrieval arrives with
/// the Milestone 3 backend.
class _Context extends ConsumerWidget {
  const _Context({required this.target});

  final Scripture target;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final context_ = ref.watch(contextAroundProvider(target.id));

    return context_.maybeWhen(
      data: (verses) => verses.isEmpty
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel('In context'),
                const SizedBox(height: AppSpacing.stackMd),
                for (final verse in verses) ...[
                  ScriptureCard(
                    reference: verse.reference,
                    text: verse.text,
                    translation: verse.translation,
                    compact: true,
                  ),
                  const SizedBox(height: AppSpacing.stackSm),
                ],
              ],
            ),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
