import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nitwixt/models/models.dart' as models;

import 'database_user_mixin.dart';

/// Handle user database
class DatabaseUser with DatabaseUserMixin {
  DatabaseUser({
    this.id,
  });

  /// Id of the user
  final String id;

  /// Get the stream
  Stream<models.User> get stream {
    return DatabaseUserMixin.userCollection.doc(id).snapshots().map<models.User>(DatabaseUserMixin.userFromDocumentSnapshot);
  }

  /// Get the value
  Future<models.User> get future async {
    final DocumentSnapshot documentSnapshot = await DatabaseUserMixin.userCollection.doc(id).get();
    return DatabaseUserMixin.userFromDocumentSnapshot(documentSnapshot);
  }


  Future<bool> exists() {
    return DatabaseUserMixin.userIdExists(id: id);
  }

  Future<void> update(Map<String, dynamic> obj) async {
    return await DatabaseUserMixin.userCollection.doc(id).update(obj);
  }

}
