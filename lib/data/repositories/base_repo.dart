import 'package:dak_louk/data/cache/cache.dart';
import 'package:dak_louk/domain/models/models.dart';
import 'package:dak_louk/data/tables/tables.dart';
import 'package:dak_louk/data/database/app_database.dart';
import 'package:dak_louk/core/utils/orm.dart';
import 'package:dak_louk/core/utils/error.dart';
import 'package:sqflite/sqflite.dart';

abstract class BaseRepositoryInterface<T extends Cacheable> {
  /// Get all models from the database
  Future<List<T>> getAll();

  /// Get a model by its ID
  Future<T?> getById(int id);

  /// Insert a new model into the database
  Future<int> insert(T model);

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
  Future<List<T>> getAll() async {
    try {
      final cacheKey = '${_getBaseCacheKey()}:all';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _expectMany(cached);
      }
      final db = await database;
      final result = await db.query(tableName);
      final models = result.map((map) => fromMap(map)).toList();
      _cache.set(cacheKey, Many(models));
      return models;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message:
            'Failed to get all ${tableName.substring(0, tableName.length - 1).toUpperCase()}',
      );
    }
  }

  @override
  Future<T?> getById(int id) async {
    try {
      final cacheKey = '${_getBaseCacheKey()}:$id';
      if (_cache.exists(cacheKey)) {
        final cached = _cache.get(cacheKey);
        return _expectSingle(cached);
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
        _cache.set(cacheKey, Single(model));
        return model;
      }
      return null;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message:
            'Failed to get ${tableName.substring(0, tableName.length - 1).toUpperCase()}',
      );
    }
  }

  @override
  Future<int> insert(T model) async {
    try {
      final db = await database;
      final cacheKey = _getBaseCacheKey();
      final map = toMap(model);
      // remove id because auto increment
      map.remove(Tables.id);
      final id = await db.insert(tableName, map);
      if (id > 0) {
        final modelWithId = fromMap({...map, Tables.id: id});
        _cache.set('$cacheKey:$id', Single(modelWithId));
        // set the list caches of the model
        _cache.get('$cacheKey:all')?.many?.add(modelWithId);
        return id;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message:
            'Failed to insert ${tableName.substring(0, tableName.length - 1).toUpperCase()}',
      );
      // set the single caches
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message:
            'Failed to insert ${tableName.substring(0, tableName.length - 1).toUpperCase()}',
      );
    }
  }

  @override
  Future<int> update(T model) async {
    try {
      if (T is CartModel) {}
      final db = await database;
      final cacheKey = _getBaseCacheKey();
      final map = toMap(model);
      final id = map[Tables.id];
      if (id > 0) {
        final statement = Clauses.where.eq(Tables.id, id);
        final rowsAffected = await db.update(
          tableName,
          map,
          where: statement.clause,
          whereArgs: statement.args,
        );
        if (rowsAffected > 0) {
          final updatedModel = fromMap(map);
          _cache.set('$cacheKey:$id', Single(updatedModel));
          // couldve used id to remove from the list but since cacheble is inaccesable to the id field of the model i couldnt
          final newCache = await getAll();
          _cache.set('$cacheKey:all', Many(newCache));
          return rowsAffected;
        }
        return 0;
      }
      return 0;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message:
            'Failed to update ${tableName.substring(0, tableName.length - 1).toUpperCase()}',
      );
    }
  }

  @override
  Future<int> delete(int id) async {
    try {
      final db = await database;
      final cacheKey = _getBaseCacheKey();
      final statement = Clauses.where.eq(Tables.id, id);
      final result = await db.delete(
        tableName,
        where: statement.clause,
        whereArgs: statement.args,
      );
      _cache.del('$cacheKey:$id');
      _cache.del('$cacheKey:all');
      // couldve used id to remove from the list but since cacheble is inaccesable to the id field of the model i couldnt
      final newCache = await getAll();
      _cache.set('$cacheKey:all', Many(newCache));
      return result;
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.INTERNAL_ERROR,
        message:
            'An unexpected error occurred while deleting ${tableName.substring(0, tableName.length - 1).toUpperCase()}',
      );
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
      if (where != null ||
          args != null ||
          orderBy != null ||
          limit != null ||
          offset != null) {
        final cacheKey = _getQueryCacheKey(where, args, orderBy, limit, offset);
        final cached = _cache.get(cacheKey);
        if (cached != null) {
          return _expectMany(cached).toList();
        }
      }
      final db = await database;
      final result = await db.query(
        tableName,
        where: where,
        whereArgs: args,
        orderBy: orderBy,
        limit: limit,
        offset: offset,
      );

      return result.map((map) => fromMap(map)).toList();
    } catch (e) {
      if (e is AppError) {
        rethrow;
      }
      throw AppError(
        type: ErrorType.DB_ERROR,
        message:
            'Failed to query ${tableName.substring(0, tableName.length - 1).toUpperCase()}',
      );
    }
  }

  // use to suffix the repo's keys to avoid conflicts with other repos or services
  String _getBaseCacheKey() {
    return 'model:${this.tableName}';
  }

  String _getQueryCacheKey(
    String? where,
    List<Object?>? args,
    String? orderBy,
    int? limit,
    int? offset,
  ) {
    final whereClause = where ?? '';
    final argsClause = args?.map((e) => e?.toString() ?? '').join(',') ?? '';
    final orderByClause = orderBy ?? '';
    final limitClause = limit?.toString() ?? '';
    final offsetClause = offset?.toString() ?? '';
    return 'model:$tableName:query:$whereClause:$argsClause:$orderByClause:$limitClause:$offsetClause';
  }

  // safer casting and checking
  List<T> _expectMany(CacheValue? value) {
    if (value == null) {
      throw AppError(
        type: ErrorType.CACHE_ERROR,
        message: 'Expected list cache',
      );
    }
    final many = value.many;
    if (many == null) {
      throw AppError(
        type: ErrorType.CACHE_ERROR,
        message: 'Expected list cache',
      );
    }
    return many.cast<T>();
  }

  T _expectSingle(CacheValue? value) {
    if (value == null) {
      throw AppError(
        type: ErrorType.CACHE_ERROR,
        message: 'Expected single cache but got null',
      );
    }

    final singleValue = value.single;
    if (singleValue == null) {
      throw AppError(
        type: ErrorType.CACHE_ERROR,
        message: 'Expected single cache but got ${value.runtimeType}',
      );
    }

    return singleValue as T;
  }
}
