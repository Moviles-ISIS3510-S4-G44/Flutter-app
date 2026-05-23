import 'dart:collection';

class LruCache<K, V> {
  final int capacity;
  final LinkedHashMap<K, V> _map = LinkedHashMap();

  LruCache({required this.capacity}) {
    if (capacity <= 0) {
      throw ArgumentError('capacity must be > 0');
    }
  }

  V? get(K key) {
    final value = _map.remove(key);
    if (value == null) return null;
    _map[key] = value;
    return value;
  }

  void put(K key, V value) {
    if (_map.containsKey(key)) {
      _map.remove(key);
    }
    _map[key] = value;
    if (_map.length > capacity) {
      _map.remove(_map.keys.first);
    }
  }

  bool containsKey(K key) => _map.containsKey(key);

  int get length => _map.length;

  void clear() => _map.clear();

  List<K> get keys => _map.keys.toList(growable: false);
}

