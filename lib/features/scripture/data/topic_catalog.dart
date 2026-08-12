/// Curated passages for each topic Selah offers (PRD §9 shortcuts, §14 groups).
///
/// Why curation rather than keyword search: the words users think in are often
/// absent from the KJV. "Relationships" appears nowhere in the text, "Anxiety"
/// only as "anxious"/"careful", "Decisions" not at all. Searching the topic name
/// would return nothing for several of the app's own advertised topics.
///
/// So these are editorial choices the *app* owns and can defend — not AI output,
/// and not dressed up as such. Each passage is well known, reads sensibly on its
/// own, and speaks to the topic without needing an interpreter.
///
/// This is a stopgap with a clear successor: Milestone 3's backend does semantic
/// retrieval over the whole corpus, at which point topics stop being a fixed
/// list. Until then, honest curation beats a keyword search that returns nothing.
///
/// Every id here is asserted against the corpus by `test/topic_catalog_test.dart`
/// — a typo would silently show an empty topic.
abstract final class TopicCatalog {
  /// Topic name (as displayed) -> corpus verse ids.
  static const topics = <String, List<String>>{
    // ------------------------------------------------- Home shortcuts (§9) ---
    'Fear': [
      'isaiah_41_10',
      'psalms_56_3',
      '2_timothy_1_7',
      'joshua_1_9',
      'psalms_27_1',
    ],
    'Purpose': [
      'romans_8_28',
      'jeremiah_29_11',
      'proverbs_19_21',
      'ephesians_2_10',
      'philippians_1_6',
    ],
    'Faith': [
      'hebrews_11_1',
      'romans_10_17',
      '2_corinthians_5_7',
      'james_1_6',
      'mark_11_22',
    ],
    'Relationships': [
      '1_corinthians_13_4',
      'ephesians_4_32',
      'proverbs_17_17',
      'colossians_3_13',
      'romans_12_10',
    ],
    'Forgiveness': [
      'ephesians_4_32',
      'colossians_3_13',
      'matthew_6_14',
      '1_john_1_9',
      'psalms_103_12',
    ],
    'Hope': [
      'romans_15_13',
      'jeremiah_29_11',
      'psalms_42_11',
      'hebrews_6_19',
      'lamentations_3_24',
    ],
    'Wisdom': [
      'james_1_5',
      'proverbs_3_5',
      'proverbs_9_10',
      'proverbs_2_6',
      'ecclesiastes_7_12',
    ],
    'Prayer': [
      'philippians_4_6',
      '1_thessalonians_5_17',
      'james_5_16',
      'psalms_145_18',
      'matthew_6_9',
    ],

    // ------------------------------------------ Explore → Emotions (§14) ---
    'Anxiety': [
      'philippians_4_6',
      '1_peter_5_7',
      'matthew_6_25',
      'psalms_94_19',
      'isaiah_26_3',
    ],
    'Loneliness': [
      'psalms_25_16',
      'deuteronomy_31_6',
      'hebrews_13_5',
      'psalms_68_6',
      'isaiah_41_10',
    ],
    'Anger': [
      'ephesians_4_26',
      'proverbs_15_1',
      'james_1_19',
      'ecclesiastes_7_9',
      'proverbs_29_11',
    ],
    'Grief': [
      'psalms_34_18',
      'matthew_5_4',
      'revelation_21_4',
      'psalms_147_3',
      'john_16_22',
    ],
    'Joy': [
      'psalms_16_11',
      'nehemiah_8_10',
      'john_15_11',
      'psalms_30_5',
      'romans_15_13',
    ],

    // ---------------------------------------------- Explore → Life (§14) ---
    'Work': [
      'colossians_3_23',
      'proverbs_16_3',
      'ecclesiastes_9_10',
      'proverbs_14_23',
      '2_thessalonians_3_10',
    ],
    'Money': [
      '1_timothy_6_10',
      'hebrews_13_5',
      'proverbs_3_9',
      'matthew_6_21',
      'philippians_4_19',
    ],
    'Decisions': [
      'proverbs_3_5',
      'proverbs_3_6',
      'james_1_5',
      'psalms_37_5',
      'proverbs_16_9',
    ],
    'Family': [
      'joshua_24_15',
      'proverbs_22_6',
      'ephesians_6_1',
      'psalms_127_3',
      'colossians_3_20',
    ],
    'Leadership': [
      'proverbs_11_14',
      '1_peter_5_2',
      'matthew_20_26',
      'proverbs_29_2',
      '1_timothy_3_2',
    ],

    // ------------------------------------- Explore → Spiritual Life (§14) ---
    'Temptation': [
      '1_corinthians_10_13',
      'matthew_26_41',
      'james_1_14',
      'hebrews_4_15',
      '2_peter_2_9',
    ],
    'Worship': [
      'psalms_95_6',
      'john_4_24',
      'psalms_100_2',
      'romans_12_1',
      'psalms_150_6',
    ],
  };

  /// Resolves a query to a topic, case-insensitively.
  ///
  /// Matches the whole query only. "Fear" resolves; "I am afraid of the future"
  /// does not — recognising intent in a sentence is retrieval work for the
  /// Milestone 3 backend, and guessing here would be pretending.
  static List<String>? idsFor(String query) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return null;
    for (final entry in topics.entries) {
      if (entry.key.toLowerCase() == needle) return entry.value;
    }
    return null;
  }

  static bool isTopic(String query) => idsFor(query) != null;
}
