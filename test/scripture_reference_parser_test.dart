import 'package:flutter_test/flutter_test.dart';
import 'package:selah/features/scripture/data/scripture_reference_parser.dart';

/// The parser decides whether a query is a reference or keywords, so its
/// failure modes are user-visible: a false positive sends someone to the wrong
/// passage, a false negative makes "John 3:16" behave like a word search.
void main() {
  // The real 66 canonical names, so prefix/ambiguity behaviour is tested
  // against the actual corpus rather than a convenient subset.
  const books = [
    'Genesis', 'Exodus', 'Leviticus', 'Numbers', 'Deuteronomy', 'Joshua',
    'Judges', 'Ruth', '1 Samuel', '2 Samuel', '1 Kings', '2 Kings',
    '1 Chronicles', '2 Chronicles', 'Ezra', 'Nehemiah', 'Esther', 'Job',
    'Psalms', 'Proverbs', 'Ecclesiastes', 'Song of Solomon', 'Isaiah',
    'Jeremiah', 'Lamentations', 'Ezekiel', 'Daniel', 'Hosea', 'Joel', 'Amos',
    'Obadiah', 'Jonah', 'Micah', 'Nahum', 'Habakkuk', 'Zephaniah', 'Haggai',
    'Zechariah', 'Malachi', 'Matthew', 'Mark', 'Luke', 'John', 'Acts',
    'Romans', '1 Corinthians', '2 Corinthians', 'Galatians', 'Ephesians',
    'Philippians', 'Colossians', '1 Thessalonians', '2 Thessalonians',
    '1 Timothy', '2 Timothy', 'Titus', 'Philemon', 'Hebrews', 'James',
    '1 Peter', '2 Peter', '1 John', '2 John', '3 John', 'Jude', 'Revelation',
  ];

  const parser = ScriptureReferenceParser(books);

  group('recognises references', () {
    test('book chapter verse', () {
      final ref = parser.parse('John 3:16')!;
      expect(ref.book, 'John');
      expect(ref.chapter, 3);
      expect(ref.verse, 16);
    });

    test('book and chapter only leaves verse null', () {
      final ref = parser.parse('Psalm 23')!;
      expect(ref.book, 'Psalms');
      expect(ref.chapter, 23);
      expect(ref.verse, isNull);
    });

    test('is case insensitive and tolerates spacing', () {
      for (final query in ['john 3:16', 'JOHN 3:16', '  John   3 : 16  ']) {
        final ref = parser.parse(query);
        expect(ref?.book, 'John', reason: query);
        expect(ref?.verse, 16, reason: query);
      }
    });

    test('accepts space and dot separators', () {
      expect(parser.parse('John 3 16')?.verse, 16);
      expect(parser.parse('John 3.16')?.verse, 16);
    });

    test('numbered books', () {
      expect(parser.parse('1 Corinthians 13:4')?.book, '1 Corinthians');
      expect(parser.parse('1 Cor 13:4')?.book, '1 Corinthians');
      expect(parser.parse('2 Timothy 1:7')?.book, '2 Timothy');
      expect(parser.parse('3 John 1:4')?.book, '3 John');
    });

    test('abbreviations', () {
      expect(parser.parse('Ps 23')?.book, 'Psalms');
      expect(parser.parse('Rev 21:4')?.book, 'Revelation');
      expect(parser.parse('Matt 5:4')?.book, 'Matthew');
      expect(parser.parse('Heb 11:1')?.book, 'Hebrews');
      expect(parser.parse('Phil 4:13')?.book, 'Philippians');
    });

    test('unique prefixes resolve, multi-word books work', () {
      expect(parser.parse('Philipp 4:13')?.book, 'Philippians');
      expect(parser.parse('Song of Solomon 2:1')?.book, 'Song of Solomon');
      expect(parser.parse('Lament 3:22')?.book, 'Lamentations');
    });

    test('a verse range keeps the start verse', () {
      final ref = parser.parse('Psalm 23:1-6')!;
      expect(ref.chapter, 23);
      expect(ref.verse, 1);
    });
  });

  group('rejects non-references', () {
    test('topics and keywords', () {
      for (final query in ['fear', 'anxiety', 'forgiveness', 'love', 'hope']) {
        expect(parser.parse(query), isNull, reason: query);
      }
    });

    test('a natural-language question', () {
      expect(parser.parse('what does the Bible say about fear'), isNull);
      expect(parser.parse('I am worried about my future'), isNull);
    });

    test('empty and punctuation-only input', () {
      for (final query in ['', '   ', ':', '3:16']) {
        expect(parser.parse(query), isNull, reason: '"$query"');
      }
    });

    test('unknown book names', () {
      expect(parser.parse('Enoch 1:1'), isNull);
      expect(parser.parse('Maccabees 2:3'), isNull);
    });

    test('ambiguous abbreviations resolve to nothing, never a guess', () {
      // "J 3" could be John, Job, Joel, Jonah, Jude, James...
      expect(parser.parse('J 3'), isNull);
      // "Jo 3" is still ambiguous: John, Job, Joel, Jonah, Joshua.
      expect(parser.parse('Jo 3'), isNull);
    });

    test('zero and negative chapters or verses', () {
      expect(parser.parse('John 0:5'), isNull);
      expect(parser.parse('John 3:0'), isNull);
    });
  });

  test('a parsed reference may still not exist — that is the repository\'s job', () {
    // Psalms has 150 chapters; the parser only checks shape, not bounds.
    final ref = parser.parse('Psalm 200:1');
    expect(ref, isNotNull);
    expect(ref!.chapter, 200);
  });
}
