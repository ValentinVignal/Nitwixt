import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import 'collections.dart' as collections;
import 'package:nitwixt/models/models.dart' as models;

class DatabaseUser {
  final String id;

  DatabaseUser({this.id});

  final CollectionReference userCollection = collections.userCollection;

  static models.User userFromSnapshot(DocumentSnapshot snapshot) {
    return models.User.fromFirebaseObject(snapshot.documentID, snapshot.data);
  }

  Stream<models.User> get user {
    return userCollection.document(id).snapshots().map(userFromSnapshot);
  }

  static Future createEmptyUser() async {
    DocumentReference documentReference = await collections.userCollection.add(models.User.empty().toFirebaseObject());
    return await collections.userCollection.document(documentReference.documentID).updateData({
      'id': documentReference.documentID,
    });
  }

  static Future createUser({models.User user}) async {
    if (user == null) {
      return createEmptyUser();
    } else {
      DocumentReference documentReference = await collections.userCollection.add(user.toFirebaseObject());
      return await collections.userCollection.document(documentReference.documentID).updateData({
        'id': documentReference.documentID,
      });
    }
  }

  static Future<bool> userIdExists({String id}) async {
    DocumentSnapshot documents = await collections.userCollection.document(id).get();
    return documents.exists;
  }

  Future<bool> exists() {
    return userIdExists(id: this.id);
  }
}

