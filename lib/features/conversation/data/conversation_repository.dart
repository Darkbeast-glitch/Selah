import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/errors/app_exception.dart';
import '../../auth/data/auth_repository.dart';
import 'models/conversation_models.dart';

/// Owns Firestore for `users/{uid}/conversations` and their messages.
class ConversationDataSource {
  ConversationDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _conversations(String uid) =>
      _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .collection(AppConstants.conversationsCollection);

  CollectionReference<Map<String, dynamic>> _messages(
    String uid,
    String conversationId,
  ) => _conversations(uid)
      .doc(conversationId)
      .collection(AppConstants.messagesCollection);

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
          message: 'You do not have access to that conversation.',
          cause: error,
          stackTrace: stackTrace,
        ),
        _ => DataException(cause: error, stackTrace: stackTrace),
      };
    }
  }

  Stream<List<Conversation>> watchConversations(String uid, {int limit = 20}) =>
      _conversations(uid)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map(Conversation.fromDoc)
                .toList(growable: false),
          );

  Future<String> createConversation(String uid, {required String title}) =>
      _guard(() async {
        final doc = await _conversations(uid).add(
          Conversation.newDoc(title: title),
        );
        return doc.id;
      });

  Future<void> deleteConversation(String uid, String conversationId) =>
      _guard(() async {
        // Firestore does not cascade: subcollections outlive a deleted parent
        // and would leave orphaned messages the user can no longer see or
        // remove. Delete the messages first.
        final messages = await _messages(uid, conversationId).get();
        final batch = _firestore.batch();
        for (final doc in messages.docs) {
          batch.delete(doc.reference);
        }
        batch.delete(_conversations(uid).doc(conversationId));
        await batch.commit();
      });

  Future<List<Message>> messages(
    String uid,
    String conversationId, {
    int limit = AppConstants.messagePageSize,
  }) => _guard(() async {
    final snapshot = await _messages(uid, conversationId)
        .orderBy('createdAt')
        .limit(limit)
        .get();
    return snapshot.docs.map(Message.fromDoc).toList(growable: false);
  });

  /// Deletes every conversation for [uid], messages included.
  ///
  /// Part of PRD §36. Conversations are the most sensitive data Selah holds, so
  /// this walks each thread's messages rather than relying on any cascade —
  /// Firestore has none, and orphaned messages under a deleted parent would be
  /// unreachable *and* undeleted, which is the worst of both.
  Future<void> deleteAll(String uid) => _guard(() async {
    while (true) {
      final threads = await _conversations(uid).limit(50).get();
      if (threads.docs.isEmpty) return;

      for (final thread in threads.docs) {
        final messages = await _messages(uid, thread.id).get();
        final batch = _firestore.batch();
        for (final message in messages.docs) {
          batch.delete(message.reference);
        }
        batch.delete(thread.reference);
        await batch.commit();
      }

      if (threads.docs.length < 50) return;
    }
  });

  Future<void> addMessage(
    String uid,
    String conversationId, {
    required MessageRole role,
    required String content,
  }) => _guard(() async {
    final batch = _firestore.batch();
    batch.set(
      _messages(uid, conversationId).doc(),
      Message.newDoc(role: role, content: content),
    );
    // Keep the thread at the top of History.
    batch.update(_conversations(uid).doc(conversationId), Conversation.touch());
    await batch.commit();
  });
}

/// Conversation history in application terms.
abstract interface class ConversationRepository {
  Stream<List<Conversation>> watchConversations();

  /// Records a user message, creating the thread on the first one.
  /// Returns the conversation id.
  Future<String> recordMessage({
    required String? conversationId,
    required String content,
  });

  Future<List<Message>> messages(String conversationId);
  Future<void> delete(String conversationId);
}

class FirestoreConversationRepository implements ConversationRepository {
  const FirestoreConversationRepository(this._dataSource, this._uid);

  final ConversationDataSource _dataSource;
  final String _uid;

  @override
  Stream<List<Conversation>> watchConversations() =>
      _dataSource.watchConversations(_uid);

  @override
  Future<String> recordMessage({
    required String? conversationId,
    required String content,
  }) async {
    final id = conversationId ??
        await _dataSource.createConversation(
          _uid,
          title: Conversation.titleFrom(content),
        );
    await _dataSource.addMessage(
      _uid,
      id,
      role: MessageRole.user,
      content: content,
    );
    return id;
  }

  @override
  Future<List<Message>> messages(String conversationId) =>
      _dataSource.messages(_uid, conversationId);

  @override
  Future<void> delete(String conversationId) =>
      _dataSource.deleteConversation(_uid, conversationId);
}

// ------------------------------------------------------------- providers ---

final conversationDataSourceProvider = Provider<ConversationDataSource>(
  (ref) => ConversationDataSource(FirebaseFirestore.instance),
);

final conversationRepositoryProvider = Provider<ConversationRepository>(
  (ref) => FirestoreConversationRepository(
    ref.watch(conversationDataSourceProvider),
    ref.watch(currentUidProvider),
  ),
);

/// History, most recently updated first.
final conversationsProvider = StreamProvider<List<Conversation>>(
  (ref) => ref.watch(conversationRepositoryProvider).watchConversations(),
);

/// The stored messages of a thread, for resuming from History.
///
/// Only *user* messages are stored. The Scripture shown in reply is re-derived
/// on replay because retrieval is deterministic — same message, same corpus,
/// same passages — so persisting it would duplicate derivable data. That changes
/// in Milestone 3: LLM responses are not reproducible, so assistant messages
/// will be persisted then (the `MessageRole.assistant` case already exists).
final conversationMessagesProvider =
    FutureProvider.family<List<Message>, String>(
  (ref, conversationId) =>
      ref.watch(conversationRepositoryProvider).messages(conversationId),
);
