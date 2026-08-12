import 'models/scripture.dart';

/// Turns what a user types into a Scripture reference, when it is one.
///
/// PRD §13: search must accept verse references, book names, topics, and
/// keywords through a single field. This decides whether the query *looks* like
/// a reference; anything it rejects falls through to keyword search.
///
/// Handles: `John 3:16`, `john 3 16`, `Ps 23`, `1 Cor 13:4`, `Psalm 23:1-6`
/// (start verse wins), `Song of Solomon 2:1`. Deliberately does not guess at
/// misspellings — a wrong passage is worse than no passage.
class ScriptureReferenceParser {
  const ScriptureReferenceParser(this._bookNames);

  /// Canonical book names from the corpus (`books.name`).
  final List<String> _bookNames;

  /// `1 Cor 13:4`, `John 3:16`, `Psalm 23`, `Ps 23 1`
  ///
  /// group 1 = book (may be prefixed by a number), 2 = chapter, 3 = verse
  static final _pattern = RegExp(
    r'^\s*((?:[1-3]\s*)?[A-Za-z][A-Za-z\s]*?)\s*'      // book
    r'(\d{1,3})'                                       // chapter
    r'(?:\s*[:.\s]\s*(\d{1,3}))?'                      // optional verse
    r'(?:\s*[-–]\s*\d{1,3})?\s*$',                     // optional range end
    caseSensitive: false,
  );

  /// Common abbreviations that are not simple prefixes of the full name.
  static const _aliases = {
    'ps': 'Psalms',
    'psalm': 'Psalms',
    'song': 'Song of Solomon',
    'songs': 'Song of Solomon',
    'sos': 'Song of Solomon',
    'ecc': 'Ecclesiastes',
    'phil': 'Philippians',
    'philem': 'Philemon',
    'jas': 'James',
    'rev': 'Revelation',
    'acts': 'Acts',
    'matt': 'Matthew',
    'mk': 'Mark',
    'lk': 'Luke',
    'jn': 'John',
    'heb': 'Hebrews',
    'gen': 'Genesis',
    'ex': 'Exodus',
    'deut': 'Deuteronomy',
    'prov': 'Proverbs',
    'isa': 'Isaiah',
    'jer': 'Jeremiah',
    'lam': 'Lamentations',
    'ezek': 'Ezekiel',
    'dan': 'Daniel',
    'zech': 'Zechariah',
    'mal': 'Malachi',
    'rom': 'Romans',
    'cor': 'Corinthians',
    'gal': 'Galatians',
    'eph': 'Ephesians',
    'col': 'Colossians',
    'thess': 'Thessalonians',
    'tim': 'Timothy',
    'pet': 'Peter',
  };

  /// Returns a [ScriptureRef] when [query] names a passage, else null.
  ScriptureRef? parse(String query) {
    final match = _pattern.firstMatch(query.trim());
    if (match == null) return null;

    final book = _resolveBook(match.group(1)!);
    if (book == null) return null;

    final chapter = int.tryParse(match.group(2)!);
    if (chapter == null || chapter < 1) return null;

    final verse = match.group(3) == null ? null : int.tryParse(match.group(3)!);
    if (verse != null && verse < 1) return null;

    return ScriptureRef(book: book, chapter: chapter, verse: verse);
  }

  /// Resolves user input to a canonical book name, or null if ambiguous.
  String? _resolveBook(String raw) {
    // Normalise "1st John" / "1john" / "1  John" to "1 john".
    //
    // These must use replaceAllMapped: Dart's replaceAll treats the replacement
    // as a literal string, so r'$1' would insert the characters "$1" rather
    // than the captured digit.
    final input = raw
        .toLowerCase()
        .replaceAllMapped(RegExp(r'(\d)(st|nd|rd)\b'), (m) => m[1]!)
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAllMapped(RegExp(r'^(\d)\s*'), (m) => '${m[1]} ')
        .trim();

    for (final name in _bookNames) {
      if (name.toLowerCase() == input) return name;
    }

    // Split a leading number so "1 cor" can match the "Corinthians" alias.
    final numMatch = RegExp(r'^([1-3])\s+(.*)$').firstMatch(input);
    final ordinal = numMatch?.group(1);
    final bare = numMatch?.group(2) ?? input;

    final aliased = _aliases[bare.replaceAll('.', '')];
    if (aliased != null) {
      final candidate = ordinal == null ? aliased : '$ordinal $aliased';
      for (final name in _bookNames) {
        if (name.toLowerCase() == candidate.toLowerCase()) return name;
      }
    }

    // Unique prefix match ("Philipp" -> Philippians). Ambiguity returns null
    // rather than picking one, so "j 3" never silently becomes John.
    final prefixed = _bookNames
        .where((n) => n.toLowerCase().startsWith(input))
        .toList();
    if (prefixed.length == 1) return prefixed.first;

    if (ordinal != null) {
      final matches = _bookNames
          .where((n) => n.toLowerCase().startsWith('$ordinal ') &&
              n.toLowerCase().substring(2).startsWith(bare))
          .toList();
      if (matches.length == 1) return matches.first;
    }

    return null;
  }
}
