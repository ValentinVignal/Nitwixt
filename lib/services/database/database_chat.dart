import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
    return DatabaseChatMixin.chatCollection.doc(id).snapshots().map(DatabaseChatMixin.chatFromDocumentSnapshot);
  }

  /// Value of the chat
  Future<models.Chat> get future async {
    final DocumentSnapshot documentSnapshot = await DatabaseChatMixin.chatCollection.doc(id).get();
    return DatabaseChatMixin.chatFromDocumentSnapshot(documentSnapshot);
  }


  Future<void> update(Map<String, dynamic> obj) async {
    return await DatabaseChatMixin.chatCollection.doc(id).update(obj);
  }

  Future<String> updateMembers(List<String> usernames) async {
//    final user = await collections.userPrivateCollection.where('id', isEqualTo: 'chats').where('username', isEqualTo: 'e').get();
//    print('user ${user.docs.length}');
//    final user1 = user.docs[0].data();
//    print('user $user, ${user1['username']}, ${user1['chats']}');
//    return Future<String>.value('ok');
  // S0uZHm99wAPT72RySQfR
    try {
      final HttpsCallable httpsCallable = CloudFunctions.instance.getHttpsCallable(functionName: 'updateChat');
      final HttpsCallableResult response = await httpsCallable.call(<String, dynamic>{
        'type': 'members',
        'value': usernames,
        'chatId': id,
      });
      final Map<String, dynamic> data = Map<String, dynamic>.from(response.data as Map<dynamic, dynamic>);
      final String error = data.containsKey('error') ? data['error'] as String : '';
      if (error.isNotEmpty) {
        return Future<String>.error(error);
      } else {
        return Future<String>.value('');
      }
    } catch (error) {
      return Future<String>.error('The members couldn\'t be updated');
    }
    /*
    final List<models.User> allUserList = await DatabaseUserMixin.usersFromField(usernames);
    final DocumentSnapshot documentSnapshot = await DatabaseChatMixin.chatCollection.doc(id).get();
    final models.Chat chat = DatabaseChatMixin.chatFromDocumentSnapshot(documentSnapshot);

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
     */
  }

  /// Delete the chat
  Future<void> delete({List<models.User> members}) async {
    return await DatabaseChatMixin.chatCollection.doc(id).delete();
  }
}
