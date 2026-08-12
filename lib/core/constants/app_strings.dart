/// Every user-facing string in Selah.
///
/// The wording here is not incidental — PRD §2, §18, §25, and §34 constrain it.
/// Before changing copy, check that it still holds:
///
/// * Never imply the AI has divine authority ("God told me", "God wants you").
/// * Never call a generated prayer anything but a "prayer starter".
/// * Never use guilt or streak language in reminders.
abstract final class AppStrings {
  // ------------------------------------------------------------ onboarding ---
  static const onboardingPause = 'Pause.';
  static const onboardingBringQuestions = 'Bring your questions.';
  static const onboardingReturnToWord = 'Return to the Word.';
  static const onboardingBegin = 'Begin';

  // ------------------------------------------------------------------ home ---
  static const greetingMorning = 'Good morning';
  static const greetingAfternoon = 'Good afternoon';
  static const greetingEvening = 'Good evening';

  static const homePrompt = 'What are you carrying today?';
  static const homeInputHint = "Share what's on your mind...";
  static const homeTopicsLabel = 'Or start with a topic';
  static const homeTodaysScripture = "Today's Scripture";
  static const homeReflectPrompt = 'Take a moment to reflect.';

  // ---------------------------------------------------------- conversation ---
  static const conversationInputHint = 'Continue the conversation...';
  static const conversationScriptureLabel = 'Scripture';
  static const conversationWhyLabel = 'Why this passage';
  static const conversationReflectLabel = 'Reflect';
  static const conversationConsiderLabel = 'Consider this';
  static const conversationOpening = "Let's explore what Scripture says about this.";

  // --------------------------------------------------------------- explore ---
  static const exploreTitle = 'Explore Scripture';
  static const exploreSearchHint = 'Search Scripture, topics, or questions...';
  static const exploreTopicsLabel = 'Topics to explore';
  static const explorePopularLabel = 'Popular passages';

  // ----------------------------------------------------- scripture / reader ---
  static const scriptureRelatedLabel = 'Related passages';
  static const scriptureReflectAction = 'Reflect on this passage';
  static const scriptureReadContext = 'Read context';
  static const scriptureSave = 'Save';
  static const scriptureSaved = 'Saved';
  static const scriptureShare = 'Share';
  static const scriptureCopy = 'Copy';
  static const scriptureHighlight = 'Highlight';

  // --------------------------------------------------------------- library ---
  static const libraryTitle = 'Your Library';
  static const librarySavedTab = 'Saved';
  static const libraryHistoryTab = 'History';

  // ------------------------------------------------------------ reflection ---
  static const reflectionTitle = 'Reflect';
  static const reflectionPrompt = 'What is this passage making you think about?';
  static const reflectionHint = 'Write your thoughts...';
  static const reflectionSave = 'Save reflection';
  static const reflectionToPrayer = 'Turn this into a prayer';
  static const reflectionPrivacyNote = 'Your reflections are private.';

  // ---------------------------------------------------------------- prayer ---
  /// PRD §18: label it exactly this. Never "God's prayer", "God's response",
  /// or "what God wants you to pray".
  static const prayerStarterLabel = 'Prayer starter';
  static const prayerEdit = 'Edit';
  static const prayerSave = 'Save prayer';
  static const prayerRegenerate = 'Regenerate';

  // --------------------------------------------------------------- profile ---
  static const profileJourneyLabel = 'Your Journey';
  static const profilePreferencesLabel = 'Preferences';
  static const profileAboutLabel = 'About';
  static const profileAccountLabel = 'Account';
  static const profileSavedScriptures = 'Saved Scriptures';
  static const profileReflections = 'Reflections';
  static const profilePrayers = 'Prayers';
  static const profileConversationHistory = 'Conversation history';
  static const profileTranslation = 'Bible translation';
  static const profileNotifications = 'Notifications';
  static const profileAppearance = 'Appearance';
  static const profileLanguage = 'Language';
  static const profileAboutSelah = 'About Selah';
  static const profilePrivacy = 'Privacy';
  static const profileTerms = 'Terms';
  static const profileScriptureSources = 'Scripture sources';
  static const profileDeleteData = 'Delete my data';

  // ------------------------------------------------------------ navigation ---
  static const navHome = 'Home';
  static const navExplore = 'Explore';
  static const navLibrary = 'Library';
  static const navProfile = 'Profile';

  // ---------------------------------------------------------------- states ---
  static const loadingScripture = 'Finding relevant Scripture...';
  static const errorTitle = 'Let’s try again.';
  static const errorRetry = 'Try again';
  static const emptyLibraryTitle = 'Your library is waiting.';
  static const emptyLibraryBody =
      'Scriptures you save will gather here, ready when you need them.';
  static const emptyHistoryTitle = 'Start wherever you are.';
  static const emptyHistoryBody =
      'Bring a question, a worry, or a hope. Your conversations will appear here.';

  /// PRD §37 — the exact offline message.
  static const offlineMessage =
      "You're offline. You can still read your saved Scriptures and reflections.";

  // --------------------------------------------------------- notifications ---
  /// PRD §34 — gentle, never guilt-based, never streak language.
  static const notificationTitles = [
    'A moment to pause.',
    'Take a moment with Scripture.',
    'Your quiet moment is waiting.',
  ];

  // -------------------------------------------------------------- guardrails ---
  /// Shown wherever the app explains what Selah is (onboarding, about).
  /// PRD §2 — Selah does not replace God, Scripture, or human support.
  static const aiDisclosure =
      'Selah helps you discover and reflect on Scripture. It is not a '
      'substitute for Scripture itself, your church, a pastor, or '
      'professional care.';

  /// PRD §25 — surfaced when a conversation touches crisis or severe distress.
  static const crisisSupportNote =
      'If you are in immediate danger or crisis, please reach out to someone '
      'you trust or your local emergency or crisis service right away.';
}
