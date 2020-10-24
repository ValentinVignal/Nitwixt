import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'collections.dart';
import 'database_user.dart';

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

  Future<void> setTokens(List<String> tokens_) async {
    if (tokens_.length > maxTokens) {
      tokens_.sublist(tokens_.length - maxTokens);
    }
    return await userCollection.doc(id).update(<String, dynamic>{UserKeys.pushToken: tokens_});
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

  Future<void> newToken(String token) async {
    final List<String> existingTokens = await userPushTokens;
    if (!existingTokens.contains(token)) {
      // We have to upload it
      existingTokens.add(token);
      return setTokens(existingTokens);
    } else {
      return Future<void>.value();
    }
  }

  Future<void> removeToken(String token) async {
    final List<String> _tokens = await userPushTokens;
    if (_tokens.contains(token)) {
      // I have to delete it
      _tokens.remove(token);
      return await setTokens(_tokens);
    } else {
      return Future<void>.value();
    }
  }
}
