import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/services/database/database.dart';
import 'package:equatable/equatable.dart';
import 'package:nitwixt/src/src.dart' as src;


class MessageKeys {
  static const String id = 'id';
  static const String date = 'date';
  static const String text = 'text';
  static const String userid = 'userid';
  static const String reacts = 'reacts';
  static const String previousMessageId = 'previousMessageId';
  static const String images = 'images';
  static const String chatid = 'chatid';
}

class Message with EquatableMixin {
  Message({
    this.id,
    this.date,
    this.text,
    this.userid,
    this.reacts,
    this.previousMessageId = '',
    this.images,
    this.chatid,
  }) {
    reacts ??= MessageReacts();
  }

  Message.fromFirebaseObject(this.id, Map<String, dynamic> firebaseObject)
//      : date = Timestamp(int.parse(firebaseObject[MessageKeys.date]['_seconds'].toString()), int.parse(firebaseObject[MessageKeys.date]['_nanoseconds'].toString())) {
      : date = firebaseObject[MessageKeys.date] as Timestamp {
    text = firebaseObject.containsKey(MessageKeys.text) ? firebaseObject[MessageKeys.text].toString() : '';
    userid = firebaseObject.containsKey(MessageKeys.userid) ? firebaseObject[MessageKeys.userid].toString() : '';
    reacts = firebaseObject.containsKey(MessageKeys.reacts)
        ? MessageReacts.fromFirebaseObject(Map<String, String>.from(firebaseObject[MessageKeys.reacts] as Map<dynamic, dynamic>))
        : MessageReacts();
    previousMessageId = firebaseObject.containsKey(MessageKeys.previousMessageId) ? firebaseObject[MessageKeys.previousMessageId].toString() : '';
    images = firebaseObject.containsKey(MessageKeys.images) ? List<String>.from(firebaseObject[MessageKeys.images] as Iterable<dynamic>) : <String>[];
    chatid = firebaseObject.containsKey(MessageKeys.chatid) ? firebaseObject[MessageKeys.chatid].toString() : '';
  }

  String id; // Id of the message
  Timestamp date; // When the message has been sent
  String text; // The text of the message
  String userid; // The user who sent the message
  MessageReacts reacts;
  String previousMessageId;
  List<String> images = <String>[];
  String chatid;

  Message _previousMessage;

  @override
  List<Object> get props => <Object>[id, date, text, userid, previousMessageId, chatid];

  Map<String, Object> toFirebaseObject() {
    final Map<String, Object> firebaseObject = <String, Object>{};

    firebaseObject[MessageKeys.id] = id;
    firebaseObject[MessageKeys.date] = date;
    firebaseObject[MessageKeys.text] = text;
    firebaseObject[MessageKeys.userid] = userid;
    firebaseObject[MessageKeys.reacts] = reacts.toFirebaseObject();
    firebaseObject[MessageKeys.previousMessageId] = previousMessageId;
    firebaseObject[MessageKeys.images] = images;
    firebaseObject[MessageKeys.chatid] = chatid;

    return firebaseObject;
  }

  Future<Message> answersToMessage(String chatId) async {
    if (previousMessageId.isEmpty) {
      return null;
    } else {
      print('Previous message ${_previousMessage == null} - $text');
      _previousMessage ??= await DatabaseMessage(chatId: chatId).getMessageFuture(previousMessageId);
      return _previousMessage;
    }
  }

  void setNumImages(int numImages, {String chatId}) {
    assert(!((chatid == null || chatid.isEmpty) && (chatId == null || chatId.isEmpty)), 'message.chatid and chatId can t be both null or empty');
    chatId ??= chatid;
    images = <String>[];
    for (int i = 0; i < numImages; i++) {
      images.add('chats/$chatId/messages/$id/image_$i');
    }
  }

  Future<String> get imageUrl async {
    if (images.isEmpty) {
      return '';
    } else {
      return await DatabaseFiles(path: images[0]).url;
    }
  }

  bool equals(Message message) {
    return message is Message &&
        message != null &&
        message.id == id &&
        message.date == date &&
        message.text == text &&
        message.userid == userid &&
        message.reacts.equals(reacts) &&
        message.previousMessageId == previousMessageId &&
        src.listEquals(message.images, images) &&
        message.chatid == chatid;
  }

  Message copy() {
    return Message(
      id: id,
      date: date,
      text: text,
      userid: userid,
      reacts: reacts.copy(),
      previousMessageId: previousMessageId,
      images: List<String>.of(images),
      chatid: chatid
    );
  }
}

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
