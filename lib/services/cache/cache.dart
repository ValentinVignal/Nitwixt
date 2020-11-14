import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

abstract class Cachable<T> with EquatableMixin {
  T get cacheId;

  Cachable<T> copy();

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
      handleData: (List<T> receivedData, EventSink<List<T>> sink) {

        if (_update(receivedData)) {
          sink.add(data);
        }
      }
    ));
  }

  bool _update(List<T> updatedData) {
    bool isUpdated = false;
    final List<K> newOrder = updatedData.map<K>((T item) => item.cacheId).toList();
    if (!ListEquality<K>().equals(_order, newOrder)) {
      isUpdated = true;
      _order = newOrder;
    }
    for (final T item in updatedData) {
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
    print('order in data $_order');
    return _order.map((K cacheId) => _cache[cacheId]).toList();
  }
}


class CachedWidgets<K, T extends Cachable<K>> {

  CachedWidgets({
    this.shouldClear = false,
  });

  /// Whether the hidden objects should be cleared after each update
  final bool shouldClear;

  Map<K, T> _objects = <K, T>{};
  Map<K, Widget> _widgets = <K, Widget>{};
  List<K> order = <K>[];

  bool get isEmpty => order.isEmpty;

  bool get isNotEmpty => order.isNotEmpty;

  int get length => order.length;

  List<T> get objects {
    return order.map((K cacheId) {
      return _objects[cacheId];
    }).toList();
  }

  List<Widget> get widgets {
    return order.map((K cacheId) {
      return _widgets[cacheId];
    }).toList();
  }

  void add(T object, Widget widget ) {
    if(!_objects.containsKey(object.cacheId) || _objects[object.cacheId] != object) {

      _objects[object.cacheId] = object.copy() as T;
      _widgets[object.cacheId] = widget;
    }
  }

  void addAll(List<T> objectList, List<Widget> widgetList) {
    assert(objectList.length == widgetList.length, 'objectList and widgetList should have the same length');
    for (int i = 0; i < objectList.length; i++) {
      add(objectList[i], widgetList[i]);
    }
  }

  void setAll(List<T> objectList, List<Widget> widgetList) {
    assert(objectList.length == widgetList.length, 'objectList and widgetList should have the same length');
    addAll(objectList, widgetList);
    order = objectList.map((T object) => object.cacheId).toList();
    if (shouldClear) {
      _removeOthers(order);
    }
  }

  void _removeOthers(List<K> cacheIdList) {
    _objects.removeWhere((K cacheId, T object) => !order.contains(cacheId));
    _widgets.removeWhere((K cacheId, Widget widget) => !order.contains(cacheId));
  }

  void clear() {
    _objects = <K, T>{};
    _widgets = <K, Widget>{};
    order = <K>[];
  }
}