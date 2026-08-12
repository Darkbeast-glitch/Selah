import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'library_models.freezed.dart';

/// The things a user keeps: bookmarks, reflections, prayers (PRD §21).
///
/// These are mapped to Firestore by hand (`fromDoc`/`toMap`) rather than with
/// `json_serializable`. Firestore documents are not JSON — timestamps arrive as
/// [Timestamp] and are written as [FieldValue.serverTimestamp] sentinels, which
/// a generated codec cannot round-trip. Hand-mapping keeps the conversion
/// explicit and in one place, next to the model it belongs to.
///
/// Note what is *not* stored: verse text. A bookmark holds only the corpus
/// `scriptureId`, and the text is resolved locally from the bundled corpus. One
/// source of truth for Scripture, and saved items stay correct if the
/// translation ever changes.

/// A saved passage.
@freezed
abstract class Bookmark with _$Bookmark {
  const factory Bookmark({
    required String id,
    required String scriptureId,
    required String translation,
    required DateTime createdAt,
  }) = _Bookmark;

  factory Bookmark.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Bookmark(
      id: doc.id,
      scriptureId: data['scriptureId'] as String? ?? '',
      translation: data['translation'] as String? ?? '',
      createdAt: _dateFrom(data['createdAt']),
    );
  }

  static Map<String, Object?> newDoc({
    required String scriptureId,
    required String translation,
  }) => {
    'scriptureId': scriptureId,
    'translation': translation,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

/// A private reflection on a passage (PRD §17 — private by default).
@freezed
abstract class Reflection with _$Reflection {
  const factory Reflection({
    required String id,
    required String scriptureId,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Reflection;

  factory Reflection.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Reflection(
      id: doc.id,
      scriptureId: data['scriptureId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _dateFrom(data['createdAt']),
      updatedAt: _dateFrom(data['updatedAt'] ?? data['createdAt']),
    );
  }

  static Map<String, Object?> newDoc({
    required String scriptureId,
    required String content,
  }) => {
    'scriptureId': scriptureId,
    'content': content,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static Map<String, Object?> update(String content) => {
    'content': content,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

/// A prayer starter the user has kept and possibly edited (PRD §18).
@freezed
abstract class Prayer with _$Prayer {
  const factory Prayer({
    required String id,
    required String scriptureId,
    required String content,
    required DateTime createdAt,
  }) = _Prayer;

  factory Prayer.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Prayer(
      id: doc.id,
      scriptureId: data['scriptureId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _dateFrom(data['createdAt']),
    );
  }

  static Map<String, Object?> newDoc({
    required String scriptureId,
    required String content,
  }) => {
    'scriptureId': scriptureId,
    'content': content,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

/// Firestore timestamps are null for a moment after a local write, before the
/// server value lands. Falling back to "now" keeps freshly saved items sorting
/// correctly instead of jumping to 1970 and then moving.
DateTime _dateFrom(Object? value) => switch (value) {
  Timestamp() => value.toDate(),
  DateTime() => value,
  _ => DateTime.now(),
};
