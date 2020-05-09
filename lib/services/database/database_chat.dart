import 'package:cloud_firestore/cloud_firestore.dart';

import 'collections.dart' as collections;
import 'package:textwit/models/models.dart' as models;

class DatabaseChat {
  final String id;

  DatabaseChat({this.id});

  final CollectionReference chatCollection = collections.chatCollection;

  models.Chat _chatFromSnapshot(DocumentSnapshot snapshot) {
    return models.Chat.fromFirebaseObject(snapshot.documentID, snapshot.data);
  }

  Stream<models.Chat> get chat {
    return chatCollection.document(id).snapshots().map(_chatFromSnapshot);
  }

  List<models.Message> _chatMessagesFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((doc) {
      return models.Message.fromFirebaseObject(doc.documentID, doc.data);
    }).toList();
  }

  Stream<List<models.Message>> get messageList {

    return chatCollection.document(id).collection('messages').orderBy('date', descending: true).snapshots().map(_chatMessagesFromSnapshot);
  }

  Stream<List<models.Message>> getMessageList({DocumentSnapshot startAfter, int limit = 10}) {
    Query q = chatCollection.document(id).collection('messages').orderBy('date', descending: true);
    if (startAfter != null) {
      q = q.startAt([startAfter.data]);
    }
    q = q.limit(limit);
    return q.snapshots().map(_chatMessagesFromSnapshot);

  }

  Future sendMessage(String text, models.ChatPublic user) {
    return chatCollection.document(id).collection('messages').add(
      {
        'text': text,
        'date': Timestamp.now(),
        'user': {
          'id': user.id,
          'name': user.name,
        },
      },
      );
  }
}
