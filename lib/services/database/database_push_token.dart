import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nitwixt/models/models.dart';
import 'database_user.dart';

class DatabasePushToken extends DatabaseUser {

  DatabasePushToken({
    String id,
  }) : super(id: id);

  int maxTokens = 3;

  Future<List<String>> get tokens async {
    return await userCollection.document(id).get().then((DocumentSnapshot documentSnapshot) {
      final List<String> tokens = documentSnapshot.data.containsKey(UserKeys.pushToken) ? List<String>.from(documentSnapshot.data[UserKeys.pushToken] as Iterable<String>) : <String>[];
      // Make it maximum 3
      if (tokens.length > maxTokens) {
        return tokens.sublist(tokens.length - maxTokens);
      } else {
        return tokens;
      }
    });
  }

  Future<void> setTokens(List<String> tokens_) async {
    if (tokens_.length > maxTokens) {
      tokens_.sublist(tokens_.length - maxTokens);
    }
    return await userCollection.document(id).updateData(<String, dynamic>{UserKeys.pushToken: tokens_});
  }

  Future<void> newToken(String token) async {
    final List<String> existingTokens = await tokens;
    if (!existingTokens.contains(token)) {
      // We have to upload it
      existingTokens.add(token);
      return setTokens(existingTokens);
    } else {
      return Future<void>.value();
    }
  }

  Future<void> removeToken(String token) async {
    final List<String> _tokens = await tokens;
    if (_tokens.contains(token)) {
      // I have to delete it
      _tokens.remove(token);
      return await setTokens(_tokens);
    } else {
      return Future<void>.value();
    }
  }
}
