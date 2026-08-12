/// App-wide constants that are not user-facing copy.
///
/// User-facing text lives in `app_strings.dart`.
abstract final class AppConstants {
  static const String appName = 'Selah';
  static const String tagline = 'Pause. Reflect. Return to Scripture.';

  /// Default Bible translation code.
  ///
  /// PRD §12 requires a translation whose licensing explicitly permits this
  /// use, and requires the translation to be configurable. KJV is public
  /// domain, so it carries no licensing risk for the MVP corpus.
  static const String defaultTranslation = 'KJV';

  /// Firestore collection and subcollection names. Keep these in one place so
  /// data sources and security rules never drift apart.
  static const String usersCollection = 'users';
  static const String conversationsCollection = 'conversations';
  static const String messagesCollection = 'messages';
  static const String bookmarksCollection = 'bookmarks';
  static const String reflectionsCollection = 'reflections';
  static const String prayersCollection = 'prayers';

  /// Page sizes — PRD §39 requires pagination for history and search.
  static const int conversationPageSize = 20;
  static const int messagePageSize = 30;
  static const int searchPageSize = 25;
  static const int libraryPageSize = 20;
}

/// A topic shortcut on the Home screen (PRD §9).
enum HomeTopic {
  fear('Fear'),
  purpose('Purpose'),
  faith('Faith'),
  relationships('Relationships'),
  forgiveness('Forgiveness'),
  hope('Hope'),
  wisdom('Wisdom'),
  prayer('Prayer');

  const HomeTopic(this.label);
  final String label;
}

/// The three Explore category groups (PRD §14).
enum ExploreGroup {
  emotions('Emotions', [
    'Anxiety',
    'Fear',
    'Loneliness',
    'Anger',
    'Grief',
    'Joy',
    'Hope',
  ]),
  life('Life', [
    'Purpose',
    'Work',
    'Relationships',
    'Money',
    'Decisions',
    'Family',
    'Leadership',
  ]),
  spiritualLife('Spiritual Life', [
    'Faith',
    'Prayer',
    'Forgiveness',
    'Wisdom',
    'Temptation',
    'Worship',
  ]);

  const ExploreGroup(this.label, this.topics);
  final String label;
  final List<String> topics;
}
