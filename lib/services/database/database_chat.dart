import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/models/models.dart' as models;

import 'collections.dart' as collections;
import 'database_chat_mixin.dart';
import 'database_user.dart';
import 'database_user_mixin.dart';

class DatabaseChat with DatabaseChatMixin{
  DatabaseChat({
    this.id,
  });

  /// The id of the chat
  final String id;

  /// The stream of a chat
  Stream<models.Chat> get stream {
    return DatabaseChatMixin.chatCollection.document(id).snapshots().map(chatFromDocumentSnapshot);
  }

  /// Value of the chat
  Future<models.Chat> get future async {
    final DocumentSnapshot documentSnapshot = await DatabaseChatMixin.chatCollection.document(id).get();
    return DatabaseChatMixin.chatFromDocumentSnapshot(documentSnapshot);
  }


  Future<void> update(Map<String, dynamic> obj) async {
    return await DatabaseChatMixin.chatCollection.document(id).updateData(obj);
  }

  Future updateMembers(List<String> usernames) async {
    final List<models.User> allUserList = await DatabaseUserMixin.usersFromField(usernames);
    final DocumentSnapshot documentSnapshot = await DatabaseChatMixin.chatCollection.document(id).get();
    models.Chat chat = DatabaseChatMixin.chatFromDocumentSnapshot(documentSnapshot);

    // members field of the new chat
    final List<String> members = allUserList.map<String>((models.User user) {
      return user.id;
    }).toList();
    members.sort();

    final List<models.User> membersToUpdate = allUserList.where((models.User user) {
      return !user.chats.contains(id);
    }).toList();

    if (chat.members == members || membersToUpdate.isEmpty) {
      return Future<String>.value('No changes of members');
    }
    await update(<String, List<String>>{models.ChatKeys.members: members});
    membersToUpdate.forEach((models.User user) {
      user.chats.add(id);
      DatabaseUser(id: user.id).update(<String, dynamic>{
        models.UserKeys.chats: user.toFirebaseObject()[models.UserKeys.chats], // Only update the chats to prevent bugs
      });
    });
    return Future<void>.value(null);
  }

  /// Delete the chat
  Future delete({List<models.User> members}) async {
    // Reconstruct members if not provided
    if (members == null) {
      final models.Chat chat = await future;
      members = await DatabaseUserMixin.usersFromField(chat.members, fieldName: 'id');
    }

    // Delete the chat in the user documents
    members.forEach((models.User member) async {
      member.chats.remove(id);
      await DatabaseUser(id: member.id).update(<String, dynamic>{
        models.UserKeys.chats: member.toFirebaseObject()[models.UserKeys.chats],
      });
    });

    // Remove the chat
    return DatabaseChatMixin.chatCollection.document(id).delete();
  }
}
