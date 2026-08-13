import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/ai_repository.dart';

/// One turn's state: what the user said, and how the reply is going.
class TurnState {
  const TurnState({required this.message, required this.turn});

  final String message;
  final AsyncValue<ConversationTurn> turn;

  TurnState copyWith({AsyncValue<ConversationTurn>? turn}) =>
      TurnState(message: message, turn: turn ?? this.turn);
}

/// Owns the conversation.
///
/// This exists because the conversation is **stateful across turns** and the
/// previous per-message provider was not: each message was sent to the backend
/// in isolation, so a follow-up like "so what can I do about it?" arrived with
/// no idea what "it" was. The model could not continue a conversation because it
/// was never shown one.
///
/// Holding the turns here means each request carries the prior exchange, and the
/// backend's system prompt can then do its job ("if the conversation has prior
/// turns, continue it").
class ConversationController extends Notifier<List<TurnState>> {
  @override
  List<TurnState> build() => const [];

  /// Clears state for a freshly-opened screen.
  ///
  /// The provider is not family-scoped, so opening a second conversation must
  /// start from empty rather than inherit the last one's turns.
  void reset() => state = const [];

  /// Sends a message and appends its turn.
  Future<void> send(String message) async {
    final index = state.length;
    state = [
      ...state,
      TurnState(message: message, turn: const AsyncValue.loading()),
    ];

    final result = await AsyncValue.guard(
      () => ref.read(aiRepositoryProvider).reflectOn(
            message,
            history: _historyBefore(index),
          ),
    );

    // The screen may have been disposed mid-flight; Riverpod tolerates the
    // write, but guard against an index that no longer exists after a reset.
    if (index >= state.length) return;
    state = [...state]..[index] = state[index].copyWith(turn: result);
  }

  Future<void> retry(int index) async {
    if (index >= state.length) return;
    final message = state[index].message;
    state = [...state]..[index] = state[index].copyWith(
      turn: const AsyncValue.loading(),
    );

    final result = await AsyncValue.guard(
      () => ref.read(aiRepositoryProvider).reflectOn(
            message,
            history: _historyBefore(index),
          ),
    );
    if (index >= state.length) return;
    state = [...state]..[index] = state[index].copyWith(turn: result);
  }

  /// Rebuilds a thread from stored messages **without calling the backend**.
  ///
  /// Reopening a ten-message conversation from History must not fire ten paid
  /// requests to regenerate replies the user already read. Retrieval is local
  /// and free, so restored turns show their passages; the commentary is not
  /// re-generated. (Persisting assistant turns is the proper fix, and belongs
  /// with the rest of Milestone 4's history work.)
  Future<void> restore(List<String> messages) async {
    state = [
      for (final message in messages)
        TurnState(message: message, turn: const AsyncValue.loading()),
    ];

    final repository = ref.read(aiRepositoryProvider);
    for (var index = 0; index < messages.length; index++) {
      final result = await AsyncValue.guard(
        () => repository.passagesOnlyFor(messages[index]),
      );
      if (index >= state.length) return;
      state = [...state]..[index] = state[index].copyWith(turn: result);
    }
  }

  /// The exchange before [index], flattened for the backend.
  ///
  /// Only turns that actually produced a reply contribute an assistant message —
  /// a failed turn would otherwise leave the model answering a question it never
  /// saw a response to.
  List<({String role, String content})> _historyBefore(int index) {
    final history = <({String role, String content})>[];
    for (final turn in state.take(index)) {
      history.add((role: 'user', content: turn.message));
      final reply = turn.turn.value?.reflection?.response;
      if (reply != null) history.add((role: 'assistant', content: reply));
    }
    return history;
  }
}

final conversationControllerProvider =
    NotifierProvider<ConversationController, List<TurnState>>(
  ConversationController.new,
);
