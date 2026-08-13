import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/app_exception.dart';

/// Owns the `firebase_auth` API. Nothing above this file imports FirebaseAuth.
///
/// PRD §20: authentication is silent. There is no login screen — on first
/// launch the user is signed in anonymously and their Firebase UID becomes the
/// application identity. Upgrading an anonymous account to email/Google/Apple
/// is explicitly out of MVP scope.
class AuthDataSource {
  AuthDataSource(this._auth);

  final FirebaseAuth _auth;

  /// Emits on sign-in, sign-out, and token refresh.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Returns the existing session if there is one, otherwise creates an
  /// anonymous account. Safe to call on every launch.
  Future<User> signInAnonymouslyIfNeeded() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;

    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) {
        throw const AuthException(
          message: 'Sign-in succeeded but returned no user.',
        );
      }
      return user;
    } on FirebaseAuthException catch (error, stackTrace) {
      throw switch (error.code) {
        'network-request-failed' => NetworkException(
          cause: error,
          stackTrace: stackTrace,
        ),
        'operation-not-allowed' => AuthException(
          message:
              'Anonymous sign-in is disabled for this Firebase project. '
              'Enable it under Authentication → Sign-in method.',
          cause: error,
          stackTrace: stackTrace,
        ),
        _ => AuthException(cause: error, stackTrace: stackTrace),
      };
    }
  }

  /// A fresh Firebase ID token, for authenticating against Selah's own backend.
  ///
  /// The backend verifies this signature against Google's public keys and trusts
  /// the `sub` claim as the uid — which is why no API key or user identifier
  /// ever needs to travel from the app (PRD §22/§23).
  ///
  /// `getIdToken()` refreshes automatically when the cached token is near
  /// expiry, so this is safe to call per request; the SDK caches for us.
  Future<String?> idToken() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken();
    } on FirebaseAuthException catch (error, stackTrace) {
      throw AuthException(cause: error, stackTrace: stackTrace);
    }
  }

  /// PRD §36 requires a working "delete my data" path. Deleting the auth user
  /// is the last step — the caller must remove Firestore data first, because a
  /// deleted user can no longer satisfy the security rules that guard it.
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await user.delete();
    } on FirebaseAuthException catch (error, stackTrace) {
      throw AuthException(
        message: 'We could not delete your account. Please try again.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }
}
