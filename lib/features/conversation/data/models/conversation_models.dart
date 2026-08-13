import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_models.freezed.dart';

/// Conversation history (PRD §21).
///
/// Hand-mapped to Firestore for the same reason as the library models: server
/// timestamp sentinels do not round-trip through a generated codec.

enum MessageRole {
  user,
  assistant;

  static MessageRole from(String? value) =>
      value == 'assistant' ? MessageRole.assistant : MessageRole.user;
}

/// A conversation thread. [title] is derived locally from the opening message —
/// see [Conversation.titleFrom].
@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String title,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Conversation;

  factory Conversation.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Conversation(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled',
      createdAt: _dateFrom(data['createdAt']),
      updatedAt: _dateFrom(data['updatedAt'] ?? data['createdAt']),
    );
  }

  static Map<String, Object?> newDoc({required String title}) => {
    'title': title,
    'createdAt': FieldValue.serverTimestamp(),
    'updatedAt': FieldValue.serverTimestamp(),
  };

  static Map<String, Object?> touch() => {
    'updatedAt': FieldValue.serverTimestamp(),
  };

  /// A short title from the opening message.
  ///
  /// The PRD's examples ("Finding direction", "Learning to forgive") are
  /// paraphrases, which only an LLM can produce honestly. Until the backend
  /// exists this truncates the user's own words instead of inventing a summary —
  /// less elegant, but it never misrepresents what they said.
  static String titleFrom(String message) {
    final clean = message.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) return 'Untitled';
    if (clean.length <= 42) return clean;

    // Cut on a word boundary rather than mid-word.
    final cut = clean.substring(0, 42);
    final lastSpace = cut.lastIndexOf(' ');
    return '${lastSpace > 20 ? cut.substring(0, lastSpace) : cut}…';
  }
}

/// One message in a thread.
@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required MessageRole role,
    required String content,
    required DateTime createdAt,
  }) = _Message;

  factory Message.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    return Message(
      id: doc.id,
      role: MessageRole.from(data['role'] as String?),
      content: data['content'] as String? ?? '',
      createdAt: _dateFrom(data['createdAt']),
    );
  }

  static Map<String, Object?> newDoc({
    required MessageRole role,
    required String content,
  }) => {
    'role': role.name,
    'content': content,
    'createdAt': FieldValue.serverTimestamp(),
  };
}

DateTime _dateFrom(Object? value) => switch (value) {
  Timestamp() => value.toDate(),
  DateTime() => value,
  _ => DateTime.now(),
};
