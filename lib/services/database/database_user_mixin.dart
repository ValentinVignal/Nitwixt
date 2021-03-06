import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/src/utils/streams.dart' as streams;

import 'collections.dart' as collections;

mixin DatabaseUserMixin {
  /// Users collection
  static final CollectionReference userCollection = collections.userCollection;

  /// User from document snapshot
  static models.User userFromDocumentSnapshot(DocumentSnapshot snapshot) {
    return models.User.fromFirebaseObject(snapshot.id, snapshot.data());
  }

  /// List of users from document snapshot
  static List<models.User> userFromQuerySnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map(userFromDocumentSnapshot).toList();
  }

  static Future<Stream<List<models.User>>> getUserList({String chatid}) async {
    final Query queryUserChats = collections.userPublicCollection.where('id', isEqualTo: 'chats').where('chats', arrayContains: chatid);
    // TODO(Valentin): Replace get by snapshot
    final Stream<QuerySnapshot> querySnapshotStreamUserChats = queryUserChats.snapshots();

    //final List<Stream<models.User>> listStream =
    final Stream<Stream<List<models.User>>> streamStreamUsers = querySnapshotStreamUserChats.map((QuerySnapshot querySnapshotUserChats) {
      final List<Stream<models.User>> listStream = querySnapshotUserChats.docs.map((QueryDocumentSnapshot queryDocumentSnapshot) {
        return queryDocumentSnapshot.reference.parent.parent.snapshots().map<models.User>(userFromDocumentSnapshot);
      }).toList();
      return streams.combineListOfStreams<models.User>(listStream);
    });

    // Flatten the streams
    final Stream<List<models.User>> streamUsers = Rx.switchLatest(streamStreamUsers);
    return streamUsers;
  }

  static Future<Stream<Map<String, models.User>>> getUserMap({String chatid}) async {
    final Stream<List<models.User>> streamUserList = await getUserList(chatid: chatid);
    return streamUserList.map<Map<String, models.User>>((List<models.User> userList) {
      return userList.asMap().map<String, models.User>((int index, models.User user) {
        return MapEntry<String, models.User>(user.id, user);
      });
    });
  }

  /// `id` is used when I have to create a user with a fixed id (from the FirebaseUser id)
  /// If user if not provided, an empty one is created
  /// If id is not provided, an automatic id will be generated by Firebase
  static Future<String> createUser({String id, @required models.User user}) async {
    assert(user.hasUsername, 'user has to have a username');
    String realId; // The final id
    if (id == null || id.isEmpty) {
      realId = user.id;
    } else {
      realId = id;
    }
    if (realId == null || realId.isEmpty) {
      // There is no id provided as an argument or in the user
      final DocumentReference documentReference = await collections.userCollection.add(user.toFirebaseObject());
      await collections.userCollection.doc(documentReference.id).update(<String, dynamic>{
        'id': documentReference.id,
      });
      realId = documentReference.id;
    } else {
      // I have an id to consider
      user.id = realId;
      await collections.userCollection.doc(realId).set(user.toFirebaseObject());
    }
    // Create user private chat
    await collections.userCollection.doc(realId).collection('user.public').doc('chats').set(<String, dynamic>{
      'id': 'chats',
      'userId': realId,
      'username': user.username,
      'chats': <String>[],
    });
    return realId;
  }

  static Future<bool> userIdExists({String id}) async {
    final DocumentSnapshot documents = await collections.userCollection.doc(id).get();
    return documents.exists;
  }

  static Future<List<models.User>> usersFromField(List<String> fieldValuesList, {String fieldName = 'username'}) async {
    if (fieldValuesList.isEmpty) {
      return Future.error('No username provided');
    }
    // Get the
    final List<QuerySnapshot> documentsList = await Future.wait(fieldValuesList.map((String username) async {
      return await collections.userCollection.where(fieldName, isEqualTo: username).get();
    }));
    final List<String> unknownUsers = <String>[];
    documentsList.asMap().forEach((int index, QuerySnapshot documents) {
      if (documents.docs.isEmpty) {
        unknownUsers.add(fieldValuesList[index]);
      }
    });
    if (unknownUsers.isNotEmpty) {
      // Some users have not been found
      if (unknownUsers.length == 1) {
        return Future.error('User "${unknownUsers[0]}" doesn\'t exist');
      } else {
        return Future.error('Users "${unknownUsers.join('", "')}" don\'t exist');
      }
    }
    // All the users have been found
    final List<models.User> allUserList = documentsList.map<models.User>((QuerySnapshot documents) {
      return userFromDocumentSnapshot(documents.docs[0]);
    }).toList();

    return allUserList;
  }
}
