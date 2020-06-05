import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_user.dart';

class DatabasePushToken extends DatabaseUser {
  int maxTokens = 3;

  DatabasePushToken({String id}) : super(id: id);

  Future<List<String>> get tokens async {
    return await userCollection.document(id).get().then((DocumentSnapshot documentSnapshot) {
      List<String> tokens =  documentSnapshot.data.containsKey('pushToken') ? List.from(documentSnapshot.data['pushToken']) : [];
      // Make it maximum 3
      if (tokens.length > maxTokens) {
        return tokens.sublist(tokens.length - maxTokens);
      } else {
        return tokens;
      }
    });
  }

  Future setTokens(List<String> tokens_) async {
    if (tokens_.length > maxTokens) {
      tokens_.sublist(tokens_.length - maxTokens);
    }
    return await userCollection.document(id).updateData({'pushToken': tokens_});

  }

  Future newToken(String token) async {
    List<String> existingTokens = await this.tokens;
    if (!existingTokens.contains(token)) {
      // We have to upload it
      existingTokens.add(token);
      return setTokens(existingTokens);
    } else {
      return Future.value();
    }
  }

  Future removeToken(String token) async {
    List<String> _tokens = await this.tokens;
    if (_tokens.contains(token)) {
      // I have to delete it
      _tokens.remove(token);
      return await setTokens(_tokens);
    } else {
      return Future.value();
    }
  }
}

