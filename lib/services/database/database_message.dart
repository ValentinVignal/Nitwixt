import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'collections.dart';
import 'database_chat.dart';
import 'database_files.dart';

class DatabaseMessage extends DatabaseChat {
  DatabaseMessage({String chatId}) : super(id: chatId);

  static models.Message messageFromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return models.Message.fromFirebaseObject(documentSnapshot.documentID, documentSnapshot.data);
  }

  static List<models.Message> messagesFromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map(messageFromDocumentSnapshot).toList();
  }

  Stream<List<models.Message>> get messageList {
    return chatCollection
        .document(id)
        .collection(CollectionNames.messages)
        .orderBy(models.MessageKeys.date, descending: true)
        .snapshots()
        .map(messagesFromQuerySnapshot);
  }

  Stream<List<models.Message>> getList({DocumentSnapshot startAfter, int limit = 10}) {
    Query query = chatCollection.document(id).collection(CollectionNames.messages).orderBy(models.MessageKeys.date, descending: true);
    if (startAfter != null) {
      query = query.startAt(<dynamic>[startAfter.data]);
    }
    query = query.limit(limit);
    return query.snapshots().map(messagesFromQuerySnapshot);
  }

  /// Send a message
  Future<void> send({String text, String userid, String previousMessageId = '', File image}) async {
    final models.Message message = models.Message(
      id: '',
      date: Timestamp.now(),
      text: text,
      userid: userid,
      previousMessageId: previousMessageId ?? '',
      chatid: id,
      images: image != null ? <String>[''] : <String>[],
    );
    final DocumentReference documentReference =
        await chatCollection.document(id).collection(CollectionNames.messages).add(message.toFirebaseObject());
    message.id = documentReference.documentID;
    message.setNumImages(image == null ? 0 : 1);
    if (image != null) {
      DatabaseFiles(path: message.images[0]).uploadFile(image);
    }
    return await chatCollection
        .document(id)
        .collection(CollectionNames.messages)
        .document(documentReference.documentID)
        .updateData(<String, dynamic>{
      models.MessageKeys.id: message.toFirebaseObject()[models.MessageKeys.id],
      models.MessageKeys.images: message.toFirebaseObject()[models.MessageKeys.images],
    });
  }


  Future<void> updateMessage({String messageId, Map<String, dynamic> obj}) async {
    return await chatCollection.document(id).collection(CollectionNames.messages).document(messageId).updateData(obj);
  }

  Future<models.Message> getMessageFuture(String messageId) async {
    final DocumentSnapshot documentSnapshot = await chatCollection.document(id).collection(CollectionNames.messages).document(messageId).get();
    return messageFromDocumentSnapshot(documentSnapshot);
  }

  Future<void> deleteMessage(String messageId) async {
    return chatCollection.document(id).collection(CollectionNames.messages).document(messageId).delete();
  }

}
