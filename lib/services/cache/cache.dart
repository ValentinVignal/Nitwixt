import 'dart:async';

import 'package:equatable/equatable.dart';

abstract class Cachable<T> extends Equatable {
  T get cacheId;
}

class CachedStreamList<K, T extends Cachable<K>> {
  CachedStreamList(
    Stream<List<T>> stream,
  ) {
    clear();
    _stream = stream;
  }

  Map<K, T> _cache = <K, T>{};
  List<K> _order = <K>[];

  Stream<List<T>> _stream;


  Stream<List<T>> get stream {
    return _stream.transform(StreamTransformer<List<T>, List<T>>.fromHandlers(
      handleData: (List<T> data, EventSink<List<T>> sink) {
        if (_update(data)) {
          sink.add(this.data);
        }
      }
    ));
  }

  bool _update(List<T> updatedData) {
    bool isUpdated = false;
    final List<K> newOrder = updatedData.map<K>((T item) => item.cacheId).toList();
    if (newOrder != _order) {
      isUpdated = true;
      _order = newOrder;
    }
    for (T item in updatedData) {
      if (!_cache.containsKey(item.cacheId) || item != _cache[item.cacheId]) {
        isUpdated = true;
        _cache[item.cacheId] = item;
      }
    }
    return isUpdated;
  }

  void clear() {
    _order = <K>[];
    _cache = <K, T>{};
  }

  List<T> get data {
    return _order.map((K cacheId) => _cache[cacheId]).toList();
  }
}
