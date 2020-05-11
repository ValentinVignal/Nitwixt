import 'package:cloud_firestore/cloud_firestore.dart';

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

  static Future createEmptyUser({String id}) async {
    return await collections.userCollection.document(id).setData(models.User.empty().toFirebaseObject());
  }

  static Future createUser({String id, models.User user}) async {
    if (user == null) {
      return createEmptyUser(id: id);
    } else {
      String id_;
      if (id == null || id.isEmpty) {
        id_ = user.id;
      } else {
        id_ = id;
      }
      return await collections.userCollection.document(id_).setData(user.toFirebaseObject());
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

