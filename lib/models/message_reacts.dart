import 'package:equatable/equatable.dart';

import 'package:nitwixt/src/src.dart' as src;

class MessageReacts with EquatableMixin {
  MessageReacts({
    this.reactMap,
  }) {
    reactMap ??= <String, String>{};
  }

  MessageReacts.fromFirebaseObject(Map<String, String> firebaseObject) {
    reactMap = firebaseObject == null ? <String, String>{} : Map<String, String>.from(firebaseObject);
  }

  Map<String, String> reactMap;

  @override
  List<Object> get props => <Map<String, String>>[reactMap];

  Map<String, Object> toFirebaseObject() {
    return reactMap;
  }

  bool containsKey(String key) {
    return reactMap.containsKey(key);
  }

  String operator [](String key) {
    return reactMap[key];
  }

  void operator []=(String key, String value) {
    reactMap[key] = value;
  }

  String remove(String key) {
    return reactMap.remove(key);
  }

  int get length {
    return reactMap.length;
  }

  bool get isEmpty {
    return reactMap.isEmpty;
  }

  bool get isNotEmpty {
    return reactMap.isNotEmpty;
  }

  List<String> get keys {
    return reactMap.keys.toList();
  }

  List<String> reactList({bool unique = true}) {
    List<String> reacts = reactMap.values.toList();
    if (unique) {
      final Map<String, int> map = <String, int>{};
      for (final String react in reacts) {
        map[react] = map.containsKey(react) ? map[react] + 1 : 1;
      }
      reacts = map.keys.toList(growable: false);
      reacts.sort((String react1, String react2) => map[react2].compareTo(map[react1]));
    }
    return reacts;
  }

  bool equals(MessageReacts messageReacts) {
    return messageReacts is MessageReacts && messageReacts != null && src.mapEquals(messageReacts.reactMap, reactMap);
  }

  MessageReacts copy() {
    final MessageReacts newMessageReacts = MessageReacts();

    for(final String key in reactMap.keys) {
      newMessageReacts[key] = reactMap[key];
    }
    return newMessageReacts;
  }
}
