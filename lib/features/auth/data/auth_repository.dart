import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import 'auth_datasource.dart';

/// Exposes identity to the rest of the app in application terms.
///
/// Callers get a `uid` string, never a `User` object, so `firebase_auth` types
/// stop at this layer.
abstract interface class AuthRepository {
  /// The signed-in user's id, or null when there is no session.
  String? get currentUid;

  /// Emits the current uid on every auth change.
  Stream<String?> uidChanges();

  /// Resolves the session, creating an anonymous one if needed.
  Future<String> ensureSignedIn();

  /// A bearer token for Selah's own backend, or null when there is no session.
  Future<String?> idToken();

  /// Deletes the auth account. Remove Firestore data first.
  Future<void> deleteAccount();
}

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository(this._dataSource);

  final AuthDataSource _dataSource;

  @override
  String? get currentUid => _dataSource.currentUser?.uid;

  @override
  Stream<String?> uidChanges() =>
      _dataSource.authStateChanges().map((user) => user?.uid);

  @override
  Future<String> ensureSignedIn() async {
    final user = await _dataSource.signInAnonymouslyIfNeeded();
    return user.uid;
  }

  @override
  Future<String?> idToken() => _dataSource.idToken();

  @override
  Future<void> deleteAccount() => _dataSource.deleteAccount();
}

// ------------------------------------------------------------- providers ---

final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) => AuthDataSource(FirebaseAuth.instance),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(ref.watch(authDataSourceProvider)),
);

/// The current uid, kept live so a signed-out state can never be read as stale.
final uidChangesProvider = StreamProvider<String?>(
  (ref) => ref.watch(authRepositoryProvider).uidChanges(),
);

/// The uid every user-scoped repository should read.
///
/// `bootstrap()` guarantees a session before the first frame, so this is
/// non-null in practice. It throws rather than returning null so a Firestore
/// path can never be silently built with a missing uid.
final currentUidProvider = Provider<String>((ref) {
  final uid = ref.watch(uidChangesProvider).value ??
      ref.watch(authRepositoryProvider).currentUid;
  if (uid == null) {
    throw const AuthException(
      message: 'No session. bootstrap() must sign in before this is read.',
    );
  }
  return uid;
});
