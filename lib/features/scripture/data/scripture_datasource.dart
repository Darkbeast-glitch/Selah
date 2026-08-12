import 'package:sqflite/sqflite.dart';

import '../../../core/errors/app_exception.dart';
import 'models/scripture.dart';
import 'scripture_database.dart';

/// All SQL against the Scripture corpus lives here.
///
/// Every method is bounded — either by a single location or by an explicit
/// limit/offset — because PRD §39 forbids loading the Bible into memory.
class ScriptureDataSource {
  ScriptureDataSource(this._database);

  final ScriptureDatabase _database;

  static const _columns =
      'id, book, book_order, chapter, verse, text, translation';

  Future<Database> get _db => _database.database;

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on AppException {
      rethrow;
    } on Object catch (error, stackTrace) {
      throw DataException(
        message: 'We could not read the Scripture library.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Every book in canonical order — 66 small rows, safe to hold.
  Future<List<BibleBook>> books() => _guard(() async {
    final rows = await (await _db).query('books', orderBy: 'book_order');
    return rows.map(BibleBook.fromRow).toList(growable: false);
  });

  /// A single verse by corpus id (`psalms_23_1`).
  Future<Scripture?> verseById(String id) => _guard(() async {
    final rows = await (await _db).query(
      'verses',
      columns: _columns.split(', '),
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Scripture.fromRow(rows.first);
  });

  /// A whole chapter in verse order — what the reader displays.
  Future<List<Scripture>> chapter({
    required String book,
    required int chapter,
  }) => _guard(() async {
    final rows = await (await _db).query(
      'verses',
      columns: _columns.split(', '),
      where: 'book = ? AND chapter = ?',
      whereArgs: [book, chapter],
      orderBy: 'verse',
    );
    return rows.map(Scripture.fromRow).toList(growable: false);
  });

  /// A specific verse by reference.
  Future<Scripture?> verseAt({
    required String book,
    required int chapter,
    required int verse,
  }) => _guard(() async {
    final rows = await (await _db).query(
      'verses',
      columns: _columns.split(', '),
      where: 'book = ? AND chapter = ? AND verse = ?',
      whereArgs: [book, chapter, verse],
      limit: 1,
    );
    return rows.isEmpty ? null : Scripture.fromRow(rows.first);
  });

  /// Keyword search across verse text.
  ///
  /// `LIKE` is case-insensitive for ASCII in SQLite and the KJV text is ASCII,
  /// so no lowercased duplicate column is needed. Results are ordered
  /// canonically rather than by relevance — with no FTS5 there is no ranking to
  /// trust, and canonical order is at least predictable for a reader.
  Future<List<Scripture>> search(
    String query, {
    int limit = 25,
    int offset = 0,
  }) => _guard(() async {
    final term = query.trim();
    if (term.isEmpty) return const [];

    final rows = await (await _db).query(
      'verses',
      columns: _columns.split(', '),
      // Escape LIKE wildcards so a literal % or _ cannot match everything.
      where: "text LIKE ? ESCAPE '\\'",
      whereArgs: ['%${_escapeLike(term)}%'],
      orderBy: 'book_order, chapter, verse',
      limit: limit,
      offset: offset,
    );
    return rows.map(Scripture.fromRow).toList(growable: false);
  });

  Future<int> searchCount(String query) => _guard(() async {
    final term = query.trim();
    if (term.isEmpty) return 0;
    final rows = await (await _db).rawQuery(
      "SELECT COUNT(*) AS n FROM verses WHERE text LIKE ? ESCAPE '\\'",
      ['%${_escapeLike(term)}%'],
    );
    return (rows.first['n'] as int?) ?? 0;
  });

  /// Deterministic verse of the day: the same verse for everyone on a given
  /// date, with no storage and no repeat until the pool cycles.
  ///
  /// Drawn from a curated pool rather than at random across all 31,102 verses,
  /// because an arbitrary verse (a genealogy, an imprecation) makes a poor
  /// daily invitation — Home is the app's front door.
  Future<Scripture?> verseOfTheDay(DateTime date) => _guard(() async {
    final index = date.difference(DateTime.utc(2024, 1, 1)).inDays;
    final id = dailyPool[index.abs() % dailyPool.length];
    return verseById(id);
  });

  static String _escapeLike(String value) => value
      .replaceAll('\\', r'\\')
      .replaceAll('%', r'\%')
      .replaceAll('_', r'\_');

  /// Curated verses for Home's "Today's Scripture". Chosen to be invitational
  /// and self-contained — each reads sensibly without surrounding context.
  static const dailyPool = <String>[
    'psalms_23_1',
    'psalms_46_1',
    'psalms_46_10',
    'psalms_121_1',
    'psalms_139_14',
    'psalms_34_18',
    'psalms_55_22',
    'psalms_147_3',
    'proverbs_3_5',
    'proverbs_3_6',
    'isaiah_40_31',
    'isaiah_41_10',
    'isaiah_43_2',
    'isaiah_26_3',
    'jeremiah_29_11',
    'lamentations_3_22',
    'lamentations_3_23',
    'matthew_6_34',
    'matthew_11_28',
    'matthew_5_4',
    'john_14_27',
    'john_16_33',
    'romans_8_28',
    'romans_12_2',
    'romans_15_13',
    '1_corinthians_13_4',
    '2_corinthians_12_9',
    'galatians_5_22',
    'ephesians_2_8',
    'philippians_4_6',
    'philippians_4_7',
    'philippians_4_13',
    'colossians_3_15',
    '1_thessalonians_5_16',
    '2_timothy_1_7',
    'hebrews_11_1',
    'hebrews_13_5',
    'james_1_5',
    '1_peter_5_7',
    '1_john_4_18',
  ];
}
