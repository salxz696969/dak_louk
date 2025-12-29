import 'package:dak_louk/domain/domain.dart';

abstract class CacheInterface {
  /// Set a value in the cache
  void set<T extends Cacheable>(String key, T data);

  /// Get a value from the cache
  T? get<T extends Cacheable>(String key);

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

  final Map<String, Cacheable> _cache = {};

  @override
  void set<T extends Cacheable>(String key, T data) {
    _cache[key] = data;
  }

  @override
  T? get<T extends Cacheable>(String key) {
    return _cache[key] as T?;
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
