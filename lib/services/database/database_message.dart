import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_chat.dart';
import 'collections.dart';
import 'package:nitwixt/models/models.dart' as models;

class DatabaseMessage extends DatabaseChat {
  DatabaseMessage({chatId}) : super(chatId: chatId);

  static List<models.Message> messagesFromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((DocumentSnapshot doc) {
      return models.Message.fromFirebaseObject(doc.documentID, doc.data);
    }).toList();
  }

  Stream<List<models.Message>> get messageList {
    return chatCollection.document(chatId).collection('messages').orderBy('date', descending: true).snapshots().map(messagesFromQuerySnapshot);
  }

  Stream<List<models.Message>> getMessageList({DocumentSnapshot startAfter, int limit = 10}) {
    Query query = chatCollection.document(chatId).collection('messages').orderBy('date', descending: true);
    if (startAfter != null) {
      query = query.startAt([startAfter.data]);
    }
    query = query.limit(limit);
    return query.snapshots().map(messagesFromQuerySnapshot);
  }

  Future sendMessage({String text, String userid}) async {
    models.Message message = models.Message(id: '', date: Timestamp.now(), text: text, userid: userid);
    DocumentReference documentReference = await chatCollection.document(chatId).collection('messages').add(message.toFirebaseObject());
    return await chatCollection.document(chatId).collection('messages').document(documentReference.documentID).updateData({
      'id': documentReference.documentID,
    });
  }

  Future updateMessage({String messageId, Object obj}) async {
    return await chatCollection.document(chatId).collection('messages').document(messageId).updateData(obj);
  }
}
