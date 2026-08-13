import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../auth/data/auth_repository.dart';
import '../../conversation/data/conversation_repository.dart';
import '../../library/data/library_datasource.dart';
import '../../library/data/library_repository.dart';

/// PRD §36 — "delete my data", for real.
///
/// Orchestrates deletion across the two data sources that hold user content and
/// then the auth account. **Order is load-bearing:** `firestore.rules` scopes
/// every operation to `request.auth.uid`, so once the auth account is gone the
/// data becomes permanently unreachable *and* undeleted. Data first, account
/// last, always.
///
/// Deliberately not "best effort": if any step fails, the account is left intact
/// so the user can retry. Half-deleting someone's data and then orphaning it
/// behind a deleted account is worse than not starting.
class DataDeletionService {
  const DataDeletionService({
    required LibraryDataSource library,
    required ConversationDataSource conversations,
    required AuthRepository auth,
  })  : _library = library,
        _conversations = conversations,
        _auth = auth;

  // ignore_for_file: prefer_initializing_formals
  final LibraryDataSource _library;
  final ConversationDataSource _conversations;
  final AuthRepository _auth;

  /// Erases everything and starts a fresh anonymous session.
  ///
  /// A new session rather than a signed-out shell: Selah has no login (§20), so
  /// leaving the app with no identity would leave it unable to save anything.
  /// The user keeps a working app with nothing in it — which is what "delete my
  /// data" should mean here.
  Future<void> deleteEverything() async {
    final uid = _auth.currentUid;
    if (uid == null) {
      throw const AuthException(
        message: 'Selah could not verify your session. Please reopen the app and try again.',
      );
    }

    await _conversations.deleteAll(uid);
    await _library.deleteAll(uid);

    // Last, and only if the data is gone.
    await _auth.deleteAccount();

    // Re-establish an identity so the app remains usable.
    await _auth.ensureSignedIn();
  }
}

final dataDeletionServiceProvider = Provider<DataDeletionService>(
  (ref) => DataDeletionService(
    library: ref.watch(libraryDataSourceProvider),
    conversations: ref.watch(conversationDataSourceProvider),
    auth: ref.watch(authRepositoryProvider),
  ),
);
