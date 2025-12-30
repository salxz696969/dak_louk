import 'package:dak_louk/domain/domain.dart';

abstract class CacheInterface {
  // ! note: current implementation with setList and getList is a bit redundant and not redis style
  // ! in typescript i would do a simple type union
  // ! to solve we can use a sealed wrapper class like CacheValue with Single and Many but overkill for now
  /// Set a value in the cache
  void set<T extends Cacheable>(String key, T data);

  void setList<T extends Cacheable>(String key, List<T> data);

  /// Get a value from the cache
  T? get<T extends Cacheable>(String key);

  List<T>? getList<T extends Cacheable>(String key);

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
  void set<T extends Cacheable>(String key, T data) {
    _cache[key] = data as Object;
  }

  @override
  void setList<T extends Cacheable>(String key, List<T> data) {
    _cache[key] = data;
  }

  @override
  T? get<T extends Cacheable>(String key) {
    return _cache[key] as T?;
  }

  @override
  List<T>? getList<T extends Cacheable>(String key) {
    return _cache[key] as List<T>?;
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
