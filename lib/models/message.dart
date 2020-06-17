import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id; // Id of the message
  final Timestamp date; // When the message has been sent
  String text; // The text of the message
  String userid; // The user who sent the message
  MessageReacts reacts;

  Message({
    this.id,
    this.date,
    this.text,
    this.userid,
    this.reacts,
  }) {
    if (this.reacts == null) {
      this.reacts = MessageReacts();
    }
  }

  Map<String, Object> toFirebaseObject() {
    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['id'] = this.id;
    firebaseObject['date'] = this.date;
    firebaseObject['text'] = this.text;
    firebaseObject['userid'] = this.userid;
    firebaseObject['reacts'] = this.reacts.toFirebaseObject();

    return firebaseObject;
  }

  Message.fromFirebaseObject(String id, Map firebaseObject)
      : id = id,
        date = firebaseObject['date'] {
    this.text = firebaseObject.containsKey('text') ? firebaseObject['text'] : '';
    this.userid = firebaseObject.containsKey('userid') ? firebaseObject['userid'] : '';
    this.reacts = firebaseObject.containsKey('reacts') ? MessageReacts.fromFirebaseObject(firebaseObject['reacts']) : MessageReacts();
  }
}

class MessageReacts {
  Map<String, String> reactMap;

  MessageReacts({
    this.reactMap,
  }) {
    if (this.reactMap == null) {
      this.reactMap = Map<String, String>();
    }
  }

  Map<String, Object> toFirebaseObject() {
    return reactMap;
  }

  MessageReacts.fromFirebaseObject(Map firebaseObject) {
    this.reactMap = firebaseObject == null ? Map<String, String>() : Map.from(firebaseObject);
  }

  bool containsKey(String key) {
    return this.reactMap.containsKey(key);
  }

  String operator [](String key) {
    return this.reactMap[key];
  }

  void operator []=(String key, String value) {
    this.reactMap[key] = value;
  }

  String remove(String key) {
    return this.reactMap.remove(key);
  }

  int get length {
    return this.reactMap.values.length;
  }

  bool get isEmpty {
    return this.reactMap.isEmpty;
  }

  bool get isNotEmpty {
    return this.reactMap.isNotEmpty;
  }


  List<String> reactList({bool unique=true}) {
    List<String> reacts = this.reactMap.values.toList();
    if (unique) {
      final Map<String, int> map = Map<String, int>();
      for (final String react in reacts) {
        map[react] = map.containsKey(react) ? map[react] + 1 : 1;
      }
      reacts = map.keys.toList(growable: false);
      reacts.sort((String react1, String react2) => map[react2].compareTo(map[react1]));
    }
    return reacts;
  }
}
