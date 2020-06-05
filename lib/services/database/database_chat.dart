import 'package:cloud_firestore/cloud_firestore.dart';

import 'collections.dart' as collections;
import 'package:nitwixt/models/models.dart' as models;
import 'database_user.dart';

class DatabaseChat {
  final String chatId;

  DatabaseChat({this.chatId});

  final CollectionReference chatCollection = collections.chatCollection;

  static models.Chat chatFromDocumentSnapshot(DocumentSnapshot snapshot) {
    return models.Chat.fromFirebaseObject(snapshot.documentID, snapshot.data);
  }

  static List<models.Chat> chatFromQuerySnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map(chatFromDocumentSnapshot).toList();
  }

  Stream<models.Chat> get chat {
    return chatCollection.document(chatId).snapshots().map(chatFromDocumentSnapshot);
  }


  static Stream<List<models.Chat>> getChatList({List<String> chatIdList, int limit = 10}) {
    Query query = collections.chatCollection.where('id', whereIn: chatIdList).limit(limit);
    return query.snapshots().map(chatFromQuerySnapshot);
  }


  static Future<String> createNewChat(models.User user, List<String> usernames) async {
    /// Creates a new chat from the usernames and a user
    if (usernames.isEmpty) {
      return 'No username provided different from the user';
    }
    // Get the
    List<QuerySnapshot> documentsList = await Future.wait(usernames.where((String username) {
      return username != user.username;
    }).map((String username) async {
      return await collections.userCollection.where('username', isEqualTo: username).getDocuments();
    }));
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
      return DatabaseUser.userFromDocumentSnapshot(documents.documents[0]);
    }).toList();
    List<models.User> allUserList = [user] + otherUserList;

    // members field of the new chat
    List<String> members = allUserList.map<String>((models.User user) {
      return user.id;
    }).toList();
    members.sort();
    // Test the chat doesn't exists already
    QuerySnapshot querySnapshot = await collections.chatCollection.where('members', isEqualTo: members).getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      // The chat already exists
      return 'A chat already exists with these users';
    }

    // * ----- Create the chat -----
    models.Chat newChat = models.Chat(
      id: '',
      name: '',
      members: members,
    );
    DocumentReference documentReference = await collections.chatCollection.add(newChat.toFirebaseObject());
    String chatid = documentReference.documentID;
    newChat.id = chatid;

    if (chatid == null) {
      return 'Could not create the new chat';
    }
    await collections.chatCollection.document(chatid).updateData({
      'id': chatid,
    });
    // * ----- Update the users -----
    allUserList.forEach((models.User user) {
      user.chats.add(chatid);
      collections.userCollection.document(user.id).updateData({
        'chats': user.toFirebaseObject()['chats'], // Only update the chats to prevent bugs
      });
    });
    return null;
  }
}
