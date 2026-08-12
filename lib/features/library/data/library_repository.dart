import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/preferences_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../scripture/data/models/scripture.dart';
import '../../scripture/data/scripture_repository.dart';
import 'library_datasource.dart';
import 'models/library_models.dart';

/// A saved item paired with the passage it refers to.
///
/// Firestore stores only the `scriptureId`; the verse is resolved from the local
/// corpus. That join happens here so the UI receives something displayable and
/// never has to know the text came from a different store.
class SavedScripture {
  const SavedScripture({required this.bookmark, required this.scripture});

  final Bookmark bookmark;

  /// Null when the id is not in the current corpus — a passage saved by an older
  /// build, or a translation that is no longer bundled.
  final Scripture? scripture;
}

class SavedReflection {
  const SavedReflection({required this.reflection, required this.scripture});
  final Reflection reflection;
  final Scripture? scripture;
}

class SavedPrayer {
  const SavedPrayer({required this.prayer, required this.scripture});
  final Prayer prayer;
  final Scripture? scripture;
}

/// Everything the user keeps, in application terms.
abstract interface class LibraryRepository {
  Stream<List<SavedScripture>> watchBookmarks();
  Stream<bool> watchIsBookmarked(String scriptureId);
  Future<void> toggleBookmark(String scriptureId, {required bool isSaved});

  Stream<List<SavedReflection>> watchReflections();
  Future<String> saveReflection({
    required String scriptureId,
    required String content,
  });
  Future<void> updateReflection(String id, String content);
  Future<Reflection?> reflection(String id);

  Stream<List<SavedPrayer>> watchPrayers();
  Future<String> savePrayer({
    required String scriptureId,
    required String content,
  });
}

class FirestoreLibraryRepository implements LibraryRepository {
  /// Named parameters are used because `uid` and `translation` are both plain
  /// strings and would be trivial to transpose positionally.
  ///
  /// `prefer_initializing_formals` is suppressed for this file: its fix
  /// (`required this._uid`) does not compile, because Dart forbids named
  /// parameters that start with an underscore.
  // ignore_for_file: prefer_initializing_formals
  FirestoreLibraryRepository({
    required LibraryDataSource dataSource,
    required ScriptureRepository scripture,
    required String uid,
    required String translation,
  })  : _dataSource = dataSource,
        _scripture = scripture,
        _uid = uid,
        _translation = translation;

  final LibraryDataSource _dataSource;

  /// Resolves saved ids against the *local* corpus — Firestore never stores text.
  final ScriptureRepository _scripture;
  final String _uid;
  final String _translation;

  /// Ensures the parent user document exists before the first write. Awaited
  /// lazily and only once, so reads never pay for it.
  Future<void>? _profileReady;
  Future<void> _ensureProfile() => _profileReady ??=
      _dataSource.ensureProfile(_uid, translation: _translation);

  /// Resolves each saved id against the local corpus, in parallel.
  Future<List<Scripture?>> _resolve(Iterable<String> ids) =>
      Future.wait(ids.map(_scripture.byId));

  @override
  Stream<List<SavedScripture>> watchBookmarks() =>
      _dataSource.watchBookmarks(_uid).asyncMap((bookmarks) async {
        final verses = await _resolve(bookmarks.map((b) => b.scriptureId));
        return [
          for (var i = 0; i < bookmarks.length; i++)
            SavedScripture(bookmark: bookmarks[i], scripture: verses[i]),
        ];
      });

  @override
  Stream<bool> watchIsBookmarked(String scriptureId) =>
      _dataSource.watchIsBookmarked(_uid, scriptureId);

  @override
  Future<void> toggleBookmark(
    String scriptureId, {
    required bool isSaved,
  }) async {
    await _ensureProfile();
    if (isSaved) {
      await _dataSource.removeBookmark(_uid, scriptureId);
    } else {
      await _dataSource.addBookmark(
        _uid,
        scriptureId: scriptureId,
        translation: _translation,
      );
    }
  }

  @override
  Stream<List<SavedReflection>> watchReflections() =>
      _dataSource.watchReflections(_uid).asyncMap((reflections) async {
        final verses = await _resolve(reflections.map((r) => r.scriptureId));
        return [
          for (var i = 0; i < reflections.length; i++)
            SavedReflection(reflection: reflections[i], scripture: verses[i]),
        ];
      });

  @override
  Future<String> saveReflection({
    required String scriptureId,
    required String content,
  }) async {
    await _ensureProfile();
    return _dataSource.addReflection(
      _uid,
      scriptureId: scriptureId,
      content: content,
    );
  }

  @override
  Future<void> updateReflection(String id, String content) =>
      _dataSource.updateReflection(_uid, id, content: content);

  @override
  Future<Reflection?> reflection(String id) => _dataSource.reflection(_uid, id);

  @override
  Stream<List<SavedPrayer>> watchPrayers() =>
      _dataSource.watchPrayers(_uid).asyncMap((prayers) async {
        final verses = await _resolve(prayers.map((p) => p.scriptureId));
        return [
          for (var i = 0; i < prayers.length; i++)
            SavedPrayer(prayer: prayers[i], scripture: verses[i]),
        ];
      });

  @override
  Future<String> savePrayer({
    required String scriptureId,
    required String content,
  }) async {
    await _ensureProfile();
    return _dataSource.addPrayer(
      _uid,
      scriptureId: scriptureId,
      content: content,
    );
  }
}

// ------------------------------------------------------------- providers ---

final libraryDataSourceProvider = Provider<LibraryDataSource>(
  (ref) => LibraryDataSource(FirebaseFirestore.instance),
);

/// Depends on [currentUidProvider], so it rebuilds if the session changes and
/// can never be constructed without an identity.
final libraryRepositoryProvider = Provider<LibraryRepository>(
  (ref) => FirestoreLibraryRepository(
    dataSource: ref.watch(libraryDataSourceProvider),
    scripture: ref.watch(scriptureRepositoryProvider),
    uid: ref.watch(currentUidProvider),
    translation: ref.watch(preferencesServiceProvider).translation,
  ),
);

final bookmarksProvider = StreamProvider<List<SavedScripture>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchBookmarks(),
);

final isBookmarkedProvider = StreamProvider.family<bool, String>(
  (ref, scriptureId) =>
      ref.watch(libraryRepositoryProvider).watchIsBookmarked(scriptureId),
);

final reflectionsProvider = StreamProvider<List<SavedReflection>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchReflections(),
);

final prayersProvider = StreamProvider<List<SavedPrayer>>(
  (ref) => ref.watch(libraryRepositoryProvider).watchPrayers(),
);
