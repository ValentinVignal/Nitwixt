import 'package:cloud_firestore/cloud_firestore.dart';

import 'collections.dart' as collections;
import 'package:nitwixt/models/models.dart' as models;
import 'database_user.dart';

class DatabaseChat {
  final String id;

  DatabaseChat({this.id});

  final CollectionReference chatCollection = collections.chatCollection;

  static models.Chat chatFromDocumentSnapshot(DocumentSnapshot snapshot) {
    return models.Chat.fromFirebaseObject(snapshot.documentID, snapshot.data);
  }
  
  static List<models.Chat> chatFromQuerySnapshot(QuerySnapshot querySnapshot) {
    print('querysnapshot ${querySnapshot.documents.length}');
    return querySnapshot.documents.map((DocumentSnapshot documentSnapshot) {
//      models.Chat user = _chatFromDocumentSnapshot(documentSnapshot);
      models.Chat user = models.Chat.fromFirebaseObject(documentSnapshot.documentID, documentSnapshot.data);
      print(user);
      return user;
    }).toList();
  }

  Stream<models.Chat> get chat {
    return chatCollection.document(id).snapshots().map(chatFromDocumentSnapshot);
  }

  static List<models.Message> chatMessagesFromQuerySnapshot(QuerySnapshot snapshot) {
    return snapshot.documents.map((DocumentSnapshot doc) {
      return models.Message.fromFirebaseObject(doc.documentID, doc.data);
    }).toList();
  }

  Stream<List<models.Message>> get messageList {
    return chatCollection.document(id).collection('messages').orderBy('date', descending: true).snapshots().map(chatMessagesFromQuerySnapshot);
  }
  
  Stream<List<models.Message>> getMessageList({DocumentSnapshot startAfter, int limit = 10}) {
    Query q = chatCollection.document(id).collection('messages').orderBy('date', descending: true);
    if (startAfter != null) {
      q = q.startAt([startAfter.data]);
    }
    q = q.limit(limit);
    return q.snapshots().map(chatMessagesFromQuerySnapshot);
  }
  
  static Stream<List<models.Chat>> getChatList({List<String> chatIdList, int limit=10}) {
    print('chatList $chatIdList');

    Query query = collections.chatCollection; //.where('id', isEqualTo: chatIdList[0]);
//    query = query.limit(limit);
    return query.snapshots().map(chatFromQuerySnapshot);
  }

  Future sendMessage({String text, String userid}) {
    models.Message message = models.Message(id: '', date: Timestamp.now(), text: text, userid: userid);
    return chatCollection.document(id).collection('messages').add(message.toFirebaseObject());
  }

  static Future<String> createNewChat(models.User user, List<String> usernames) async {
    List<QuerySnapshot> documentsList = await Future.wait(usernames.where((String username) {
      return username != user.username;
    }).map((String username) async {
      return await collections.userCollection.where('username', isEqualTo: username).getDocuments();
    }));
    if (usernames.isEmpty) {
      return 'No username provided different from the user';
    }
    List<String> unkownUsers = [];
    documentsList.asMap().forEach((int index, QuerySnapshot documents) {
      if (documents.documents.isEmpty) {
        unkownUsers.add(usernames[index]);
      }
    });
    if (unkownUsers.isNotEmpty) {
      // Some users have not been found
      if (unkownUsers.length == 1) {
        return 'User "${unkownUsers[0]}" doesn\'t exist';
      } else {
        return 'Users "${unkownUsers.join('", "')}" don\'t exist';
      }
    }
    // All the users have been found
    List<models.User> otherUserList = documentsList.map((QuerySnapshot documents) {
      return DatabaseUser.userFromSnapshot(documents.documents[0]);
    }).toList();
    List<models.User> allUserList = [user] + otherUserList;

    // * ----- Create the chat -----
    models.Chat newChat = models.Chat(
      id: '',
      name: '',
      members: allUserList.map<String>((models.User user) {
        return user.id;
      }).toList(),
    );
    String chatid = await collections.chatCollection.add(
      newChat.toFirebaseObject()
    ).then((DocumentReference docRef) {
      return docRef.documentID;
    });
    newChat.id = chatid;

    if (chatid == null) {
      return 'Could not create the new chat';
    }
    // * ----- Update the users -----
    allUserList.forEach((models.User user) {
      user.chats.add(chatid);
      collections.userCollection.document(user.id).updateData({
          'chats': user.toFirebaseObject()['chats'],    // Only update the chats to prevent bugs
      });
    });
    return null;
  }
}
