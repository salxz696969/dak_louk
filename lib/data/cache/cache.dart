import 'package:dak_louk/core/utils/error.dart';
import 'package:dak_louk/domain/models/models.dart';

// cache value is a wrapper class to wrap single and many, it has methods like single and many for the usage of the result of the get method
// example: final cacheValue = cache.get<PostModel>('post:1');
// then you can use cacheValue.single or cacheValue.many to get the data (careful usage depending on the type of the cache value, using wrong method can cause null)
// basically CacheValue<T> = Single<T> | Many<T> in typescript

// NOTE:
// CacheValue is non-generic, so from a type-system perspective a Many cache
// could theoretically contain mixed Cacheable instances.
// However, cache keys are repository-scoped and owned exclusively by this
// BaseRepository<T>, which guarantees by architecture and data flow that
// all cached values under this key are of type T.
// Therefore, the cast here is safe by construction.
sealed class CacheValue {
  Cacheable? get single => this is Single ? (this as Single).data : null;
  List<Cacheable>? get many => this is Many ? (this as Many).data : null;
}

class Single extends CacheValue {
  final Cacheable data;
  Single(this.data);
  @override
  Cacheable? get single => data;
}

class Many extends CacheValue {
  final List<Cacheable> data;
  Many(this.data);
  @override
  List<Cacheable>? get many => data;
}

abstract class CacheInterface {
  // // ! note: current implementation with setList and getList is a bit redundant and not redis style
  // // ! in typescript i would do a simple type union
  // // ! to solve we can use a sealed wrapper class like CacheValue with Single and Many but overkill for now
  /// Set a value in the cache
  void set(String key, CacheValue data);

  /// Get a value from the cache
  CacheValue? get(String key);

  /// Delete a value from the cache
  void del(String key);

  void delByPrefix(String prefix);

  void delByPattern(String pattern);

  /// Check if a value exists in the cache
  bool exists(String key);

  /// Flush all values from the cache
  void flushAll();

  /// Get the cache size
  int getSize();
}

class Cache implements CacheInterface {
  // singleton
  Cache._internal();
  static final Cache _instance = Cache._internal();
  factory Cache() => _instance;

  // change from cacheble to allow for lists of cacheable objects
  final Map<String, CacheValue> _cache = {};

  @override
  void set(String key, CacheValue data) {
    _cache[key] = data;
  }

  @override
  CacheValue? get(String key) {
    return _cache[key];
  }

  @override
  void del(String key) {
    _cache.remove(key);
  }

  @override
  void delByPrefix(String prefix) {
    _cache.removeWhere((key, value) => key.startsWith(prefix));
  }

  @override
  void delByPattern(String pattern) {
    final regex = RegExp(
      '^' +
          pattern
              .replaceAll('.', r'\.')
              .replaceAll('*', '.*')
              .replaceAll('?', '.') +
          r'$',
    );

    _cache.removeWhere((key, _) => regex.hasMatch(key));
  }

  @override
  bool exists(String key) {
    return _cache.containsKey(key);
  }

  @override
  void flushAll() {
    _cache.clear();
  }

  @override
  int getSize() {
    return _cache.length;
  }

  // helper
  // copied from base repo
  // these are of type cacheable and not T like in base repo
  // becuase it can return whatever (that is cacheble ) its dumber not tied to the class type
  // used only in service layer to cache VMs

  List<Cacheable> expectMany(CacheValue? value) {
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
    return many.cast<Cacheable>();
  }

  Cacheable expectSingle(CacheValue? value) {
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

    return singleValue;
  }
}
