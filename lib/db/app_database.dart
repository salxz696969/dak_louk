// ignore: depend_on_referenced_packages
import 'package:dak_louk/db/create_table.dart';
import 'package:dak_louk/db/init_db.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._internal();
  factory AppDatabase() => _instance;
  AppDatabase._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null && _db!.isOpen) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'marketplace.db');

      return await openDatabase(
        path,
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await createTables(db);
          await insertMockData(db);
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null && _db!.isOpen) {
      await _db!.close();
      _db = null;
    }
  }
}
