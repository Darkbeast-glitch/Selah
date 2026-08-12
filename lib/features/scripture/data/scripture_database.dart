import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../../../core/errors/app_exception.dart';

/// Opens the bundled KJV corpus.
///
/// The corpus ships as a read-only asset (`assets/scripture/kjv.db`, built by
/// `tool/build_kjv_db.py`). sqflite needs a real file path, so on first launch
/// the asset is copied into the app's database directory once, then opened
/// read-only from there.
///
/// Consequences worth knowing:
/// * The Bible is fully available offline, which PRD §37 requires.
/// * Nothing here touches Firestore. The corpus is app content, not user data,
///   which is also why `firestore.rules` grants no public read path.
/// * Queries stay in SQLite rather than loading verses into memory (PRD §39).
class ScriptureDatabase {
  ScriptureDatabase({this.assetPath = _assetPath, this.fileName = _fileName});

  static const _assetPath = 'assets/scripture/kjv.db';
  static const _fileName = 'kjv.db';

  /// Bump when `tool/build_kjv_db.py` changes the schema or the corpus, so
  /// existing installs replace their copied file instead of keeping a stale one.
  static const schemaVersion = 1;

  final String assetPath;
  final String fileName;

  Database? _db;
  Future<Database>? _opening;

  /// The open database, opening it on first use. Concurrent callers share one
  /// open operation rather than racing to copy the asset.
  Future<Database> get database => _db != null
      ? Future.value(_db)
      : (_opening ??= _open().then((db) {
          _db = db;
          _opening = null;
          return db;
        }));

  Future<Database> _open() async {
    try {
      final dir = await getDatabasesPath();
      final path = p.join(dir, fileName);
      final stampFile = File(p.join(dir, '$fileName.version'));

      final stamp = stampFile.existsSync()
          ? int.tryParse(stampFile.readAsStringSync().trim())
          : null;
      final needsCopy = !File(path).existsSync() || stamp != schemaVersion;

      if (needsCopy) {
        await Directory(dir).create(recursive: true);
        final bytes = await rootBundle.load(assetPath);
        await File(path).writeAsBytes(
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          flush: true,
        );
        stampFile.writeAsStringSync('$schemaVersion');
      }

      return openReadOnlyDatabase(path);
    } on Object catch (error, stackTrace) {
      throw DataException(
        message: 'We could not open the Scripture library.',
        cause: error,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
