import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'collections.dart';

mixin DatabaseUserPushTokensKeys {
  static const String pushTokens = 'pushTokens';
}

class DatabaseUserPushTokens {
  DatabaseUserPushTokens({
    this.userId,
  });

  final String userId;

  int maxTokens = 3;

  static models.UserPushTokens userPushTokensFromDocumentSnapshot(DocumentSnapshot documentSnapshot) {
    return models.UserPushTokens.fromFirebaseObject(documentSnapshot.data());
  }

  Future<models.UserPushTokens> get userPushTokens async {
    final DocumentSnapshot documentSnapshot =
        await userCollection.doc(userId).collection(CollectionNames.userPrivate).doc(DatabaseUserPushTokensKeys.pushTokens).get();
    return userPushTokensFromDocumentSnapshot(documentSnapshot);
  }

  Future<void> update(Map<String, dynamic> object) async {
    return await userCollection.doc(userId).collection(CollectionNames.userPrivate).doc(DatabaseUserPushTokensKeys.pushTokens).update(object);
  }

  Future<void> set(models.UserPushTokens userPushTokens) async {
    return await userCollection
        .doc(userId)
        .collection(CollectionNames.userPrivate)
        .doc(DatabaseUserPushTokensKeys.pushTokens)
        .set(userPushTokens.toFirebaseObject());
  }
}
