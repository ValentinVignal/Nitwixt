import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/models/models.dart' as models;

import 'collections.dart' as collections;
import 'database_chat.dart';
import 'database_user.dart';
import 'database_user_mixin.dart';

mixin DatabaseChatMixin {


  /// Chat collection
  static final CollectionReference chatCollection = collections.chatCollection;

  /// Chat from a document snapshot
  static models.Chat chatFromDocumentSnapshot(DocumentSnapshot snapshot) {
    return models.Chat.fromFirebaseObject(snapshot.documentID, snapshot.data);
  }

  /// List of chat from a query snapshot
  static List<models.Chat> chatFromQuerySnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map(chatFromDocumentSnapshot).toList();
  }


  /// Stream of list of chat of a user
  static Stream<List<models.Chat>> getChatList({String userid, int limit = 10}) {
    final Query query = collections.chatCollection.where(models.ChatKeys.members, arrayContains: userid).limit(limit);
    return query.snapshots().map(chatFromQuerySnapshot);
  }

  // TODO(Valentin): Remove this function
  static Future<String> createNewChat(List<String> usernames) async {
    /// Creates a new chat from the usernames and a user

    final List<models.User> allUserList = await DatabaseUserMixin.usersFromField(usernames);

    // members field of the new chat
    final List<String> members = allUserList.map<String>((models.User user) {
      return user.id;
    }).toList();
    members.sort();
    // Test the chat doesn't exists already
    final QuerySnapshot querySnapshot = await collections.chatCollection.where(models.ChatKeys.members, isEqualTo: members).getDocuments();
    if (querySnapshot.documents.isNotEmpty) {
      // The chat already exists
      return Future<String>.error('A chat already exists with these users');
    }

    // * ----- Create the chat -----
    models.Chat newChat = models.Chat(
      id: '',
      name: '',
      members: members,
    );
    final DocumentReference documentReference = await collections.chatCollection.add(newChat.toFirebaseObject());
    final String chatid = documentReference.documentID;
    newChat.id = chatid;

    if (chatid == null) {
      return Future<String>.error('Could not create the new chat');
    }
    await DatabaseChat(id: chatid).update(<String, String>{
      models.ChatKeys.id: chatid,
    });
    // * ----- Update the users -----
    allUserList.forEach((models.User user) {
      user.chats.add(chatid);
      DatabaseUser(id: user.id).update(<String, dynamic>{
        models.UserKeys.chats: user.toFirebaseObject()[models.UserKeys.chats], // Only update the chats to prevent bugs
      });
//      collections.userCollection.document(user.id).updateData({
//        'chats': user.toFirebaseObject()['chats'], // Only update the chats to prevent bugs
//      });
    });
    return Future<String>.value(chatid);
  }

}