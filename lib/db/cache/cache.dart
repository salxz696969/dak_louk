import 'package:dak_louk/domain/domain.dart';

// cache value is a wrapper class to wrap single and many, it has methods like single and many for the usage of the result of the get method
// example: final cacheValue = cache.get<PostModel>('post:1');
// then you can use cacheValue.single or cacheValue.many to get the data (careful usage depending on the type of the cache value, using wrong method can cause null)
// basically CacheValue<T> = Single<T> | Many<T> in typescript
sealed class CacheValue<T extends Cacheable> {
  T? get single => this is Single<T> ? (this as Single<T>).data : null;
  List<T>? get many => this is Many<T> ? (this as Many<T>).data : null;
}

class Single<T extends Cacheable> extends CacheValue<T> {
  final T data;
  Single(this.data);
  @override
  T? get single => data;
}

class Many<T extends Cacheable> extends CacheValue<T> {
  final List<T> data;
  Many(this.data);
  @override
  List<T>? get many => data;
}

abstract class CacheInterface {
  // // ! note: current implementation with setList and getList is a bit redundant and not redis style
  // // ! in typescript i would do a simple type union
  // // ! to solve we can use a sealed wrapper class like CacheValue with Single and Many but overkill for now
  /// Set a value in the cache
  void set<T extends Cacheable>(String key, CacheValue<T> data);

  /// Get a value from the cache
  CacheValue<T>? get<T extends Cacheable>(String key);

  /// Delete a value from the cache
  void del(String key);

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
  final Map<String, Object> _cache = {};

  @override
  void set<T extends Cacheable>(String key, CacheValue<T> data) {
    _cache[key] = data as Object;
  }

  @override
  CacheValue<T>? get<T extends Cacheable>(String key) {
    return _cache[key] as CacheValue<T>?;
  }

  @override
  void del(String key) {
    _cache.remove(key);
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
}
