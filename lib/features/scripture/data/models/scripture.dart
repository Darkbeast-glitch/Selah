import 'package:freezed_annotation/freezed_annotation.dart';

part 'scripture.freezed.dart';
part 'scripture.g.dart';

/// A single verse — the atom of the whole app (PRD §12).
///
/// [id] is the stable corpus key (`psalms_23_1`): book slug, chapter, verse.
/// Bookmarks, reflections, and prayers all reference a verse by this id, so it
/// must stay stable across corpus rebuilds. `tool/build_kjv_db.py` derives it
/// deterministically from the canonical book name.
@freezed
abstract class Scripture with _$Scripture {
  const factory Scripture({
    required String id,
    required String book,
    required int bookOrder,
    required int chapter,
    required int verse,
    required String text,
    required String translation,
  }) = _Scripture;

  const Scripture._();

  factory Scripture.fromJson(Map<String, dynamic> json) =>
      _$ScriptureFromJson(json);

  /// Maps a `verses` table row. Kept here so the column names live next to the
  /// model rather than being repeated across data sources.
  factory Scripture.fromRow(Map<String, Object?> row) => Scripture(
    id: row['id']! as String,
    book: row['book']! as String,
    bookOrder: row['book_order']! as int,
    chapter: row['chapter']! as int,
    verse: row['verse']! as int,
    text: row['text']! as String,
    translation: row['translation']! as String,
  );

  /// Human-readable reference: `Psalms 23:1`.
  String get reference => '$book $chapter:$verse';

  /// The chapter this verse belongs to, for "read in context".
  String get chapterReference => '$book $chapter';
}

/// A book of the Bible, for navigation and the reader's chapter picker.
@freezed
abstract class BibleBook with _$BibleBook {
  const factory BibleBook({
    required int bookOrder,
    required String name,
    required String slug,
    required Testament testament,
    required int chapters,
  }) = _BibleBook;

  factory BibleBook.fromJson(Map<String, dynamic> json) =>
      _$BibleBookFromJson(json);

  factory BibleBook.fromRow(Map<String, Object?> row) => BibleBook(
    bookOrder: row['book_order']! as int,
    name: row['name']! as String,
    slug: row['slug']! as String,
    testament: (row['testament']! as String) == 'OT'
        ? Testament.old
        : Testament.new_,
    chapters: row['chapters']! as int,
  );
}

enum Testament {
  @JsonValue('OT')
  old,
  @JsonValue('NT')
  new_,
}

/// A parsed Scripture reference, e.g. the user typing `John 3:16` or `Psalm 23`
/// into Explore's search field (PRD §13).
@freezed
abstract class ScriptureRef with _$ScriptureRef {
  const factory ScriptureRef({
    required String book,
    required int chapter,

    /// Null when the user named a chapter but no specific verse.
    int? verse,
  }) = _ScriptureRef;
}
