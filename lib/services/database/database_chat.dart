import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nitwixt/models/models.dart' as models;

import 'collections.dart' as collections;
import 'database_user.dart';

class DatabaseChat {

  DatabaseChat({this.chatId});

  final String chatId;

  final CollectionReference chatCollection = collections.chatCollection;

  static models.Chat chatFromDocumentSnapshot(DocumentSnapshot snapshot) {
    return models.Chat.fromFirebaseObject(snapshot.documentID, snapshot.data);
  }

  static List<models.Chat> chatFromQuerySnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.documents.map(chatFromDocumentSnapshot).toList();
  }

  Stream<models.Chat> get chatStream {
    return chatCollection.document(chatId).snapshots().map(chatFromDocumentSnapshot);
  }

  Future<models.Chat> get chatFuture async {
    final DocumentSnapshot documentSnapshot = await chatCollection.document(chatId).get();
    return chatFromDocumentSnapshot(documentSnapshot);
  }


  static Stream<List<models.Chat>> getChatList({String userid, int limit = 10}) {
    final Query query = collections.chatCollection.where(models.ChatKeys.members, arrayContains: userid).limit(limit);
    return query.snapshots().map(chatFromQuerySnapshot);
  }


  static Future<String> createNewChat(List<String> usernames) async {
    /// Creates a new chat from the usernames and a user

    final List<models.User> allUserList = await DatabaseUser.usersFromField(usernames);

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
//    await collections.chatCollection.document(chatid).updateData({
//      'id': chatid,
//    });
    await DatabaseChat(chatId: chatid).update(<String, String>{
      models.ChatKeys.id: chatid,
    });
    // * ----- Update the users -----
    allUserList.forEach((models.User user) {
      user.chats.add(chatid);
      DatabaseUser(id: user.id).update({
        models.UserKeys.chats: user.toFirebaseObject()[models.UserKeys.chats], // Only update the chats to prevent bugs
      });
//      collections.userCollection.document(user.id).updateData({
//        'chats': user.toFirebaseObject()['chats'], // Only update the chats to prevent bugs
//      });
    });
    return Future<String>.value(chatid);
  }

  Future<void> update(Map<String, dynamic> obj) async {
    return await chatCollection.document(chatId).updateData(obj);
  }


  Future updateMembers(List<String> usernames) async {

    final List<models.User> allUserList = await DatabaseUser.usersFromField(usernames);
    final DocumentSnapshot documentSnapshot = await chatCollection.document(chatId).get();
    models.Chat chat = chatFromDocumentSnapshot(documentSnapshot);

    // members field of the new chat
    final List<String> members = allUserList.map<String>((models.User user) {
      return user.id;
    }).toList();
    members.sort();

    final List<models.User> membersToUpdate = allUserList.where((models.User user) {
      return !user.chats.contains(chatId);
    }).toList();

    if (chat.members == members || membersToUpdate.isEmpty) {
      return Future<String>.value('No changes of members');
    }
    await update(<String, List<String>>{
      models.ChatKeys.members: members
    });
    membersToUpdate.forEach((models.User user) {
      user.chats.add(chatId);
      DatabaseUser(id: user.id).update({
        models.UserKeys.chats: user.toFirebaseObject()[models.UserKeys.chats], // Only update the chats to prevent bugs
      });
    });
    return Future<void>.value(null);
  }

  /// Delete the chat
  Future delete({List<models.User> members}) async {
    // Reconstruct members if not provided
    if (members == null) {
      final models.Chat chat = await chatFuture;
      members = await DatabaseUser.usersFromField(chat.members, fieldName: 'id');
    }

    // Delete the chat in the user documents
    members.forEach((models.User member) async {
      member.chats.remove(chatId);
      await DatabaseUser(id: member.id).update({
        models.UserKeys.chats: member.toFirebaseObject()[models.UserKeys.chats],
      });
    });

    // Remove the chat
    return chatCollection.document(chatId).delete();
  }

}
