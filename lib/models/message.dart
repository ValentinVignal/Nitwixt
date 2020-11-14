import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/services/cache/cache.dart';
import 'package:nitwixt/services/database/database.dart';
import 'package:equatable/equatable.dart';
import 'package:nitwixt/src/src.dart' as src;
import 'package:nitwixt/widgets/link_preview/fetch_preview.dart';

import 'message_reacts.dart';


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

class Message extends Cachable<String> {
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
  Preview _preview;
  final Map<String, String> _imagesUrl = <String, String>{};

  @override
  List<Object> get props => <Object>[id, date, text, userid, previousMessageId, chatid, reacts];

  @override
  String get cacheId {
    return id;
  }

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

  Future<Message> get previousMessage async {
    if (previousMessageId.isEmpty || chatid ==null || chatid.isEmpty) {
      return null;
    } else {
      _previousMessage ??= await DatabaseMessage(chatId: chatid).getMessageFuture(previousMessageId);
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

  // bool equals(Message message) {
  //   return message is Message &&
  //       message != null &&
  //       message.id == id &&
  //       message.date == date &&
  //       message.text == text &&
  //       message.userid == userid &&
  //       message.reacts.equals(reacts) &&
  //       message.previousMessageId == previousMessageId &&
  //       src.listEquals(message.images, images) &&
  //       message.chatid == chatid;
  // }

  @override
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

  bool get hasLink => Preview.getFirstLink(text).isNotEmpty;

  Future<Preview> get preview async {
    if (_preview == null && hasLink) {
      _preview = await Preview.fetchPreview(Preview.getFirstLink(text));
    }
    return _preview;
  }

  Future<String> imageUrl({String path, int index=0}) async {
    path ??= images[index];
    if (!_imagesUrl.containsKey(path)) {
      _imagesUrl[path] = await DatabaseFiles(path: path).url;
    }
    return _imagesUrl[path];
  }

  bool get hasImages {
    return images.isNotEmpty;
  }

}

