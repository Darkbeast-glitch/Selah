import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_models.freezed.dart';
part 'ai_models.g.dart';

/// The backend's reflection response — PRD §26's contract.
///
/// Unlike the Firestore models these *are* plain JSON, so they use
/// `json_serializable` as the PRD prescribes.
///
/// Each field is rendered as its own section, never concatenated into one blob
/// (§10). That is the whole reason the contract is structured rather than a
/// single string.
@freezed
abstract class AiReflection with _$AiReflection {
  const factory AiReflection({
    /// Recognises what the person said. Never claims to know God's message.
    required String acknowledgement,

    /// One entry per passage the app supplied, with why it speaks to this.
    required List<AiScriptureNote> scriptures,

    /// The substance of the reply: answers what the person asked and teaches
    /// something, grounded in the supplied passages and attributed rather than
    /// asserted. Rendered under the design's "Consider this" label.
    required String response,

    /// The "REFLECT" section.
    required String reflectionQuestion,

    /// A gentle invitation to continue.
    required String followUpPrompt,

    /// Crisis support text (PRD §25), computed by the backend from the *user's*
    /// message rather than the model's output — so a bad generation cannot
    /// suppress it.
    ///
    /// **When non-null this must be displayed prominently.** It is not optional
    /// copy; it is the app's obligation to someone who may be in danger.
    String? safetyNotice,
  }) = _AiReflection;

  factory AiReflection.fromJson(Map<String, dynamic> json) =>
      _$AiReflectionFromJson(json);
}

@freezed
abstract class AiScriptureNote with _$AiScriptureNote {
  const factory AiScriptureNote({
    /// Corpus verse id, matching one the app supplied.
    required String id,
    required String reference,

    /// One sentence on why this passage speaks to the situation.
    required String reason,
  }) = _AiScriptureNote;

  factory AiScriptureNote.fromJson(Map<String, dynamic> json) =>
      _$AiScriptureNoteFromJson(json);
}

/// The backend's prayer-starter response (PRD §18).
@freezed
abstract class AiPrayer with _$AiPrayer {
  const factory AiPrayer({
    /// Always labelled "Prayer starter" in the UI — never "God's prayer".
    required String prayerStarter,
    String? safetyNotice,
  }) = _AiPrayer;

  factory AiPrayer.fromJson(Map<String, dynamic> json) =>
      _$AiPrayerFromJson(json);
}
