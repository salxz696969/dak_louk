import 'package:dak_louk/utils/db/app_database.dart';
import 'package:sqflite/sqflite.dart';

abstract class RepositoryBase<T> {
  /// Insert a new model into the database
  Future<int> insert(T model);

  /// Get all models from the database
  Future<List<T>> getAll();

  /// Get a model by its ID
  Future<T> getById(int id);

  /// Update an existing model in the database
  Future<int> update(T model);

  /// Delete a model by its ID
  Future<int> delete(int id);

  /// Get the table name for this repository
  String get tableName;

  /// Convert a database map to a model instance
  T fromMap(Map<String, dynamic> map);

  /// Convert a model instance to a database map
  Map<String, dynamic> toMap(T model);
}

/// Base implementation that provides common database operations
abstract class BaseRepositoryImpl<T> implements RepositoryBase<T> {
  final AppDatabase _appDatabase = AppDatabase();

  Future<Database> get database async => await _appDatabase.database;

  @override
  Future<int> insert(T model) async {
    try {
      final db = await database;
      final map = toMap(model);
      map.remove('id');
      return await db.insert(tableName, map);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<T>> getAll() async {
    try {
      final db = await database;
      final result = await db.query(tableName);
      return result.map((map) => fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<T> getById(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result.isNotEmpty) {
        return fromMap(result.first);
      }
      throw Exception(
        '${tableName.substring(0, tableName.length - 1).toUpperCase()} not found',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> update(T model) async {
    try {
      final db = await database;
      final map = toMap(model);
      final id = map['id'];
      return await db.update(tableName, map, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> delete(int id) async {
    try {
      final db = await database;
      return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to execute custom queries
  Future<List<Map<String, dynamic>>> query({
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      return await db.query(
        tableName,
        where: where,
        whereArgs: whereArgs,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to execute raw queries
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    try {
      final db = await database;
      return await db.rawQuery(sql, arguments);
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to execute custom inserts
  Future<int> insertWithConflict(
    T model,
    ConflictAlgorithm conflictAlgorithm,
  ) async {
    try {
      final db = await database;
      final map = toMap(model);
      map.remove('id');
      return await db.insert(
        tableName,
        map,
        conflictAlgorithm: conflictAlgorithm,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to check if a record exists
  Future<bool> exists(int id) async {
    try {
      final db = await database;
      final result = await db.query(
        tableName,
        columns: ['id'],
        where: 'id = ?',
        whereArgs: [id],
      );
      return result.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  /// Helper method to get count of records
  Future<int> count({String? where, List<Object?>? whereArgs}) async {
    try {
      final db = await database;
      final result = await db.query(
        tableName,
        columns: ['COUNT(*) as count'],
        where: where,
        whereArgs: whereArgs,
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      rethrow;
    }
  }
}
