import 'package:dak_louk/db/cache/cache.dart';
import 'package:dak_louk/domain/domain.dart';
import 'package:dak_louk/utils/db/app_database.dart';
import 'package:dak_louk/utils/db/orm.dart';
import 'package:dak_louk/utils/db/tables/tables.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseRepositoryInterface<T extends Cacheable> {
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

  /// Query current table
  Future<List<T>> queryThisTable({
    String? where,
    List<Object?>? args,
    String? orderBy,
    int? limit,
    int? offset,
  });
}

/// Base implementation that provides common database operations
abstract class BaseRepository<T extends Cacheable>
    implements BaseRepositoryInterface<T> {
  final AppDatabase _appDatabase = AppDatabase();
  final Cache _cache = Cache();

  Future<Database> get database async => await _appDatabase.database;

  @override
  Future<int> insert(T model) async {
    try {
      final db = await database;
      final cacheKey = _getBaseCacheKey();
      final map = toMap(model);
      map.remove('id');
      final result = await db.insert(tableName, map);
      if (result > 0) {
        _cache.set(cacheKey, model);
        return result;
      }
      throw Exception(
        'Failed to insert ${tableName.substring(0, tableName.length - 1).toUpperCase()}',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<T>> getAll() async {
    try {
      if (_cache.exists(_getBaseCacheKey())) {
        return _cache.get(_getBaseCacheKey()) as List<T>;
      }
      final db = await database;
      final result = await db.query(tableName);
      final models = result.map((map) => fromMap(map)).toList();
      _cache.set(_getBaseCacheKey(), models as Cacheable);
      return models;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<T> getById(int id) async {
    try {
      if (_cache.exists(_getBaseCacheKey())) {
        return _cache.get(_getBaseCacheKey()) as T;
      }
      final db = await database;
      final statement = Clauses.where.eq(Tables.id, id);
      final result = await db.query(
        tableName,
        where: statement.clause,
        whereArgs: statement.args,
      );
      if (result.isNotEmpty) {
        final model = fromMap(result.first);
        _cache.set(_getBaseCacheKey(), model as Cacheable);
        return model;
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
      final cacheKey = _getBaseCacheKey();
      final map = toMap(model);
      final id = map['id'];
      final statement = Clauses.where.eq(Tables.id, id);
      final result = await db.update(
        tableName,
        map,
        where: statement.clause,
        whereArgs: statement.args,
      );
      if (result > 0) {
        final updatedModel = fromMap(map);
        _cache.set(cacheKey, updatedModel as Cacheable);
        return result;
      }
      throw Exception(
        '${tableName.substring(0, tableName.length - 1).toUpperCase()} not found',
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> delete(int id) async {
    try {
      final db = await database;
      final statement = Clauses.where.eq(Tables.id, id);
      final result = await db.delete(
        tableName,
        where: statement.clause,
        whereArgs: statement.args,
      );
      if (result > 0) {
        _cache.del(_getBaseCacheKey());
        return result;
      }
      throw Exception(
        '${tableName.substring(0, tableName.length - 1).toUpperCase()} not found',
      );
    } catch (e) {
      rethrow;
    }
  }

  // query / sql helper methods
  /// Helper method to execute custom queries
  Future<List<T>> queryThisTable({
    String? where,
    List<Object?>? args,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    try {
      final db = await database;
      final result = await db.query(
        tableName,
        where: where,
        whereArgs: args,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );

      // this means that it will convert the database map to a list of models mathching it exactly with no validation
      return result.map((map) => fromMap(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // use to suffix the repo's keys to avoid conflicts with other repos or services
  String _getBaseCacheKey() {
    return 'model:${this.tableName}';
  }
}
