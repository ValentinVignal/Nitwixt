import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/models/models.dart';
import 'package:nitwixt/services/database/database.dart';

class MessageKeys {
  static final String id = 'id';
  static final String date = 'date';
  static final String text = 'text';
  static final String userid = 'userid';
  static final String reacts = 'reacts';
  static final String previousMessageId = 'previousMessageId';
}

class Message {
  final String id; // Id of the message
  final Timestamp date; // When the message has been sent
  String text; // The text of the message
  String userid; // The user who sent the message
  MessageReacts reacts;
  String previousMessageId;

  Message({
    this.id,
    this.date,
    this.text,
    this.userid,
    this.reacts,
    this.previousMessageId='',
  }) {
    if (this.reacts == null) {
      this.reacts = MessageReacts();
    }
  }

  Map<String, Object> toFirebaseObject() {
    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject[MessageKeys.id] = this.id;
    firebaseObject[MessageKeys.date] = this.date;
    firebaseObject[MessageKeys.text] = this.text;
    firebaseObject[MessageKeys.userid] = this.userid;
    firebaseObject[MessageKeys.reacts] = this.reacts.toFirebaseObject();
    firebaseObject[MessageKeys.previousMessageId] = this.previousMessageId;

    return firebaseObject;
  }

  Message.fromFirebaseObject(String id, Map firebaseObject)
      : id = id,
        date = firebaseObject[MessageKeys.date] {
    this.text = firebaseObject.containsKey(MessageKeys.text) ? firebaseObject[MessageKeys.text] : '';
    this.userid = firebaseObject.containsKey(MessageKeys.userid) ? firebaseObject[MessageKeys.userid] : '';
    this.reacts = firebaseObject.containsKey(MessageKeys.reacts) ? MessageReacts.fromFirebaseObject(firebaseObject[MessageKeys.reacts]) : MessageReacts();
    this.previousMessageId = firebaseObject.containsKey(MessageKeys.previousMessageId) ? firebaseObject[MessageKeys.previousMessageId].toString() : '';
  }

  Future<Message> answersToMessage(String chatId) async {
    if (this.previousMessageId.isEmpty) {
      return null;
    } else {
      return await DatabaseMessage(chatId: chatId).getMessageFuture(this.previousMessageId);
    }
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
