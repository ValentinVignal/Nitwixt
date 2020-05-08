import 'package:cloud_firestore/cloud_firestore.dart';

import 'collections.dart' as collections;
import 'package:textwit/models/models.dart' as models;

class DatabaseUser {
  final String id;

  DatabaseUser({this.id});

  final CollectionReference userCollection = collections.userCollection;

  models.User userFromSnapshot(DocumentSnapshot snapshot) {
    return models.User.fromFirebaseObject(snapshot.data);
  }

  Stream<models.User> get user {
    return userCollection.document(id).snapshots().map(userFromSnapshot);
  }
}
