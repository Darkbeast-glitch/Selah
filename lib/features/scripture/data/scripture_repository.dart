import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/scripture.dart';
import 'scripture_database.dart';
import 'scripture_datasource.dart';
import 'scripture_reference_parser.dart';

/// What a search produced, and how it was interpreted.
///
/// The UI needs to know *why* it got these results: a reference match should
/// open the reader, while keyword matches list. Collapsing both into a bare
/// list would throw that distinction away.
sealed class SearchOutcome {
  const SearchOutcome();
}

/// The query named a passage. [scriptures] is the verse, or the whole chapter
/// when no verse was given.
class ReferenceMatch extends SearchOutcome {
  const ReferenceMatch({required this.ref, required this.scriptures});
  final ScriptureRef ref;
  final List<Scripture> scriptures;
}

/// The query was treated as keywords.
class KeywordMatch extends SearchOutcome {
  const KeywordMatch({
    required this.query,
    required this.scriptures,
    required this.total,
  });
  final String query;
  final List<Scripture> scriptures;

  /// Total matches in the corpus, which may exceed [scriptures] (paginated).
  final int total;

  bool get hasMore => scriptures.length < total;
}

/// Nothing matched.
class NoMatch extends SearchOutcome {
  const NoMatch(this.query);
  final String query;
}

/// Reads Scripture in application terms. SQL and column names stop below here.
abstract interface class ScriptureRepository {
  Future<List<BibleBook>> books();
  Future<Scripture?> byId(String id);
  Future<List<Scripture>> chapterOf(String book, int chapter);
  Future<Scripture?> verseOfTheDay({DateTime? today});

  /// One field, three behaviours (PRD §13): reference, book name, or keywords.
  Future<SearchOutcome> search(String query, {int limit, int offset});

  /// Neighbouring verses for the reader's "related passages" strip.
  ///
  /// Deliberately *not* semantic: real relatedness needs embeddings, which live
  /// server-side in Milestone 3. Until then this returns adjacent context,
  /// which is honest — it never implies a thematic link the app cannot justify.
  Future<List<Scripture>> contextAround(Scripture scripture, {int radius});
}

class LocalScriptureRepository implements ScriptureRepository {
  LocalScriptureRepository(this._dataSource);

  final ScriptureDataSource _dataSource;

  List<BibleBook>? _booksCache;
  ScriptureReferenceParser? _parser;

  @override
  Future<List<BibleBook>> books() async =>
      _booksCache ??= await _dataSource.books();

  Future<ScriptureReferenceParser> get _referenceParser async =>
      _parser ??= ScriptureReferenceParser(
        (await books()).map((b) => b.name).toList(growable: false),
      );

  @override
  Future<Scripture?> byId(String id) => _dataSource.verseById(id);

  @override
  Future<List<Scripture>> chapterOf(String book, int chapter) =>
      _dataSource.chapter(book: book, chapter: chapter);

  @override
  Future<Scripture?> verseOfTheDay({DateTime? today}) =>
      _dataSource.verseOfTheDay(today ?? DateTime.now());

  @override
  Future<SearchOutcome> search(
    String query, {
    int limit = 25,
    int offset = 0,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return NoMatch(trimmed);

    final ref = (await _referenceParser).parse(trimmed);
    if (ref != null) {
      final scriptures = ref.verse == null
          ? await _dataSource.chapter(book: ref.book, chapter: ref.chapter)
          : [
              ?await _dataSource.verseAt(
                book: ref.book,
                chapter: ref.chapter,
                verse: ref.verse!,
              ),
            ];
      if (scriptures.isNotEmpty) {
        return ReferenceMatch(ref: ref, scriptures: scriptures);
      }
      // A parsed reference that does not exist (e.g. "Psalm 200") falls through
      // to keyword search rather than reporting nothing at all.
    }

    final results = await _dataSource.search(
      trimmed,
      limit: limit,
      offset: offset,
    );
    if (results.isEmpty) return NoMatch(trimmed);

    return KeywordMatch(
      query: trimmed,
      scriptures: results,
      total: await _dataSource.searchCount(trimmed),
    );
  }

  @override
  Future<List<Scripture>> contextAround(
    Scripture scripture, {
    int radius = 2,
  }) async {
    final chapter = await chapterOf(scripture.book, scripture.chapter);
    final index = chapter.indexWhere((v) => v.id == scripture.id);
    if (index < 0) return const [];

    final start = (index - radius).clamp(0, chapter.length);
    final end = (index + radius + 1).clamp(0, chapter.length);
    return chapter
        .sublist(start, end)
        .where((v) => v.id != scripture.id)
        .toList(growable: false);
  }
}

// ------------------------------------------------------------- providers ---

final scriptureDatabaseProvider = Provider<ScriptureDatabase>((ref) {
  final database = ScriptureDatabase();
  ref.onDispose(database.close);
  return database;
});

final scriptureDataSourceProvider = Provider<ScriptureDataSource>(
  (ref) => ScriptureDataSource(ref.watch(scriptureDatabaseProvider)),
);

final scriptureRepositoryProvider = Provider<ScriptureRepository>(
  (ref) => LocalScriptureRepository(ref.watch(scriptureDataSourceProvider)),
);

/// The 66 books, for the reader's navigation.
final booksProvider = FutureProvider<List<BibleBook>>(
  (ref) => ref.watch(scriptureRepositoryProvider).books(),
);

/// Home's "Today's Scripture".
final verseOfTheDayProvider = FutureProvider<Scripture?>(
  (ref) => ref.watch(scriptureRepositoryProvider).verseOfTheDay(),
);

/// A single verse by corpus id, for the reader and for saved items.
final scriptureByIdProvider = FutureProvider.family<Scripture?, String>(
  (ref, id) => ref.watch(scriptureRepositoryProvider).byId(id),
);

/// The chapter containing a verse, for the reader.
final chapterProvider =
    FutureProvider.family<List<Scripture>, ({String book, int chapter})>(
  (ref, args) => ref
      .watch(scriptureRepositoryProvider)
      .chapterOf(args.book, args.chapter),
);

/// Verses adjacent to a given verse, for the reader's "In context" strip.
///
/// Named for what it is — adjacency, not thematic relatedness. See
/// [ScriptureRepository.contextAround].
final contextAroundProvider =
    FutureProvider.family<List<Scripture>, String>((ref, scriptureId) async {
  final repository = ref.watch(scriptureRepositoryProvider);
  final scripture = await repository.byId(scriptureId);
  if (scripture == null) return const [];
  return repository.contextAround(scripture);
});
