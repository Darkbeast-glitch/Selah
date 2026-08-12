import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import 'models/library_models.dart';

/// Owns Firestore for everything under `users/{uid}`.
///
/// Nothing above this file imports `cloud_firestore`. Paths are built from
/// [AppConstants] so they cannot drift from `firestore.rules`, which scopes every
/// allowance to the owning uid (PRD §22).
class LibraryDataSource {
  LibraryDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _firestore.collection(AppConstants.usersCollection).doc(uid);

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    String name,
  ) => _user(uid).collection(name);

  Future<T> _guard<T>(Future<T> Function() run) async {
    try {
      return await run();
    } on FirebaseException catch (error, stackTrace) {
      throw switch (error.code) {
        'unavailable' || 'deadline-exceeded' => NetworkException(
          cause: error,
          stackTrace: stackTrace,
        ),
        'permission-denied' => AuthException(
          message: 'You do not have access to that data.',
          cause: error,
          stackTrace: stackTrace,
        ),
        _ => DataException(cause: error, stackTrace: stackTrace),
      };
    }
  }

  /// Streams map Firestore errors into the stream rather than throwing, so a
  /// watching UI shows its error state instead of crashing the frame.
  Stream<List<T>> _watch<T>(
    Query<Map<String, dynamic>> query,
    T Function(DocumentSnapshot<Map<String, dynamic>>) fromDoc,
  ) => query.snapshots().map(
    (snapshot) => snapshot.docs.map(fromDoc).toList(growable: false),
  );

  // ------------------------------------------------------------- profile ---

  /// Creates the user document if absent. Called before the first write so the
  /// parent exists and `selectedTranslation` has somewhere to live.
  Future<void> ensureProfile(String uid, {required String translation}) =>
      _guard(() async {
        final doc = _user(uid);
        final snapshot = await doc.get();
        if (snapshot.exists) return;
        // createdAt must be the server's clock — firestore.rules requires it.
        await doc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'selectedTranslation': translation,
        });
      });

  // ----------------------------------------------------------- bookmarks ---

  Stream<List<Bookmark>> watchBookmarks(String uid, {int limit = 50}) => _watch(
    _collection(uid, AppConstants.bookmarksCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit),
    Bookmark.fromDoc,
  );

  /// Bookmarks are keyed by `scriptureId` rather than an auto-id, which makes
  /// "is this saved?" a document read and saving idempotent — no duplicates if
  /// the button is tapped twice.
  Future<void> addBookmark(
    String uid, {
    required String scriptureId,
    required String translation,
  }) => _guard(
    () => _collection(uid, AppConstants.bookmarksCollection)
        .doc(scriptureId)
        .set(Bookmark.newDoc(scriptureId: scriptureId, translation: translation)),
  );

  Future<void> removeBookmark(String uid, String scriptureId) => _guard(
    () => _collection(uid, AppConstants.bookmarksCollection)
        .doc(scriptureId)
        .delete(),
  );

  Stream<bool> watchIsBookmarked(String uid, String scriptureId) =>
      _collection(uid, AppConstants.bookmarksCollection)
          .doc(scriptureId)
          .snapshots()
          .map((doc) => doc.exists);

  // --------------------------------------------------------- reflections ---

  Stream<List<Reflection>> watchReflections(String uid, {int limit = 50}) =>
      _watch(
        _collection(uid, AppConstants.reflectionsCollection)
            .orderBy('updatedAt', descending: true)
            .limit(limit),
        Reflection.fromDoc,
      );

  Future<String> addReflection(
    String uid, {
    required String scriptureId,
    required String content,
  }) => _guard(() async {
    final doc = await _collection(uid, AppConstants.reflectionsCollection).add(
      Reflection.newDoc(scriptureId: scriptureId, content: content),
    );
    return doc.id;
  });

  Future<void> updateReflection(
    String uid,
    String id, {
    required String content,
  }) => _guard(
    () => _collection(uid, AppConstants.reflectionsCollection)
        .doc(id)
        .update(Reflection.update(content)),
  );

  Future<Reflection?> reflection(String uid, String id) => _guard(() async {
    final doc =
        await _collection(uid, AppConstants.reflectionsCollection).doc(id).get();
    return doc.exists ? Reflection.fromDoc(doc) : null;
  });

  // ------------------------------------------------------------- prayers ---

  Stream<List<Prayer>> watchPrayers(String uid, {int limit = 50}) => _watch(
    _collection(uid, AppConstants.prayersCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit),
    Prayer.fromDoc,
  );

  Future<String> addPrayer(
    String uid, {
    required String scriptureId,
    required String content,
  }) => _guard(() async {
    final doc = await _collection(uid, AppConstants.prayersCollection).add(
      Prayer.newDoc(scriptureId: scriptureId, content: content),
    );
    return doc.id;
  });
}
