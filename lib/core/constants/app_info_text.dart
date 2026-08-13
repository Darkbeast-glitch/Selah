/// Long-form copy for the Profile screen's About section.
///
/// Written to describe what the app **actually does**, so it stays true as the
/// app changes. If you alter data handling, storage, or the AI path, change the
/// matching paragraph here in the same commit — a privacy description that has
/// drifted from the code is worse than none.
abstract final class AppInfoText {
  static const aboutSelah = '''
Selah is a companion for bringing real life to Scripture. You describe what you
are carrying — a worry, a question, a struggle — and Selah finds passages that
speak to it, offers context for them, and invites you to reflect.

# What Selah is not

Selah does not replace God, the Holy Spirit, Scripture itself, your church, a
pastor, a mentor, or professional care. It has no access to what God is saying to
you personally, and it will never claim to.

When it comments on a passage, it is offering context and interpretation that
Christians have historically drawn from the text — not revelation. The Scripture
is the authority; Selah is a way in.

# Where the words come from

Every verse you read comes from a Bible stored on your device. The AI never
writes Scripture — it only comments on passages the app has already found for
you. That is deliberate: it means Selah cannot invent a verse or misquote one,
even by accident.

# If you are struggling

Selah is not an emergency or professional service. If you are in danger or in
crisis, please reach out to someone you trust or your local emergency or crisis
service. Scripture is not a substitute for that help, and anyone who tells you
otherwise is wrong.
''';

  static const scriptureSources = '''
# King James Version

Selah currently uses the King James Version (KJV), which is in the public domain
and free to distribute.

The full text ships inside the app: 66 books, 1,189 chapters, and 31,102 verses.
Nothing is fetched from a server, which is why reading and searching work with no
connection at all.

# Verifying the text

The corpus was built from a KJV source with explicit verse numbering, and the
build refuses to produce a Bible unless the counts and versification are exactly
right. That check exists because a Scripture app that silently drops or
renumbers verses would be worse than useless.

# Other translations

Only translations whose licensing permits it can be included. Modern
translations are copyrighted and require permission, so adding one is a
licensing question before it is a technical one.
''';

  static const privacy = '''
This describes how Selah handles your information today, in plain language.

# What is stored, and where

Passages you save, reflections you write, prayers you keep, and your
conversations are stored in your own private area of Google Firebase, tied to an
anonymous account created automatically on first launch. No email, name, phone
number, or contact information is ever collected.

Your appearance and translation preferences stay on your device.

Nobody else can read your data. The security rules permit access only to the
account that created it, and there is no path for one user to reach another's
information.

# Your conversations

Reflections and conversations are private by default. They are personal writing,
and Selah treats them that way — they are never used for advertising and are not
shared with anyone.

# The AI

When you ask for a reflection, three things leave your device: your message, the
Bible passages the app selected, and recent turns of that conversation. They go
to Selah's own server, which adds credentials and forwards the request to an AI
provider.

This matters and deserves plain speech: **AI providers on free plans may retain
or use the text sent to them.** Before release, the provider in use and its data
terms will be named here specifically. If you would rather not send something to
an AI provider, you can use Selah entirely without the reflection feature —
reading, searching, saving, and writing all work on your own device.

# Deleting your data

Profile → Delete my data removes everything: saved passages, reflections,
prayers, conversations, and the anonymous account itself. It cannot be undone.

# Before release

This summary is written to be accurate, not to be a legal document. A reviewed
privacy policy hosted at a public address is required by both app stores and is
still outstanding.
''';

  static const terms = '''
# Using Selah

Selah is offered as a companion for reading and reflecting on Scripture. It is
free to use.

# What Selah offers, and does not

Selah surfaces Bible passages and offers context and reflection prompts. It does
not provide spiritual authority, pastoral counsel, medical advice, psychological
treatment, or emergency assistance, and it should not be relied on for any of
them.

AI-generated commentary can be mistaken or incomplete. Read the Scripture
itself, and weigh what you read against your own church, pastor, and study.

# Your writing is yours

Reflections and prayers you write remain yours. Selah stores them so you can
return to them and claims no ownership over them.

# Availability

The reflection feature depends on external services and may be unavailable or
limited at times. Reading, searching, saving, and writing continue to work
regardless.

# Before release

Like the privacy summary, this is a plain-language description rather than a
reviewed legal document, and a proper version is still outstanding.
''';
}
