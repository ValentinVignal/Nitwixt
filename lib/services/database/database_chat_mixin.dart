import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:nitwixt/services/database/database.dart';

import 'collections.dart' as collections;

mixin DatabaseChatMixin {


  /// Chat collection
  static final CollectionReference chatCollection = collections.chatCollection;

  /// Chat from a document snapshot
  static models.Chat chatFromDocumentSnapshot(DocumentSnapshot snapshot) {
    return models.Chat.fromFirebaseObject(snapshot.id, snapshot.data());
  }

  /// List of chat from a query snapshot
  static List<models.Chat> chatFromQuerySnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map(chatFromDocumentSnapshot).toList();
  }


  /// Stream of list of chat of a user
  static Stream<List<models.Chat>> getChatList({String userid, int limit = 10}) {
    final Query query = collections.chatCollection.where(models.ChatKeys.members, arrayContains: userid).limit(limit);
    return query.snapshots().map(chatFromQuerySnapshot);
  }

  static Future<String> createNewChat(List<String> usernames) async {
    final users =await  DatabaseUserMixin.usersFromField(usernames);
    print('users');
    print(users.map((user) { return '${user.id} - ${user.name} - ${user.username}'; } ));

    try {
      final HttpsCallable httpsCallable = CloudFunctions.instance.getHttpsCallable(functionName: 'createChat');
      final HttpsCallableResult response = await httpsCallable.call(<String, dynamic>{
        'usernames': usernames,
      });
      final Map<String, dynamic> data = Map<String, dynamic>.from(response.data as Map<dynamic, dynamic>);
      final String error = data.containsKey('error') ? data['error'] as String : '';
      if (error.isNotEmpty) {
        return Future<String>.error(error);
      } else {
        final String chatId = data.containsKey('chatId') ? data['chatId'] as String : '';
        return Future<String>.value(chatId);
      }
    } catch (error) {
      return Future<String>.error('The chat couldn\'t be created');
    }

  }

}