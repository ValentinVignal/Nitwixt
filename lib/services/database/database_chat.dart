import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:nitwixt/models/models.dart' as models;

import 'database_chat_mixin.dart';


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
    try {
      final HttpsCallable httpsCallable = FirebaseFunctions.instance.httpsCallable('updateChat');
      final HttpsCallableResult<Map<String, dynamic>> response = await httpsCallable.call<Map<String, dynamic>>(<String, dynamic>{
        'type': 'members',
        'value': usernames,
        'chatId': id,
      });
      final Map<String, dynamic> data = Map<String, dynamic>.from(response.data);
      final String error = data.containsKey('error') ? data['error'] as String : '';
      if (error.isNotEmpty) {
        return Future<String>.error(error);
      } else {
        return Future<String>.value('');
      }
    } catch (error) {
      return Future<String>.error('The members couldn\'t be updated');
    }
  }

  /// Delete the chat
  Future<void> delete({List<models.User> members}) async {
    return await DatabaseChatMixin.chatCollection.doc(id).delete();
  }
}
