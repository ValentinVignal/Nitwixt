import 'package:nitwixt/models/models.dart';

mixin UserPushTokensKeys {
  static const String userId = 'userId';
  static const String username = 'username';
  static const String tokens = 'tokens';
  static const String id = 'id';
  static const String pushTokens = 'pushTokens';
}

class UserPushTokens {
  UserPushTokens({
    this.userId,
    this.username,
    this.tokens,
  });

  UserPushTokens.fromFirebaseObject(Map<String, dynamic> firebaseObject) {
    if (firebaseObject != null) {
      userId = firebaseObject.containsKey(UserPushTokensKeys.userId) ? firebaseObject[UserPushTokensKeys.userId] as String : '';
      username = firebaseObject.containsKey(UserPushTokensKeys.username) ? firebaseObject[UserPushTokensKeys.username] as String : '';
      tokens = firebaseObject.containsKey(UserPushTokensKeys.tokens)
          ? List<String>.from(firebaseObject[UserPushTokensKeys.tokens] as List<dynamic>)
          : <String>[];
    }
  }

  String userId = '';
  String username = '';
  List<String> tokens = <String>[];

  final int maxTokens = 3;

  String get current {
    if (tokens.isEmpty) {
      return null;
    } else {
      return tokens.last;
    }
  }

  bool add(String token) {
    if (!tokens.contains(token)) {
      tokens.add(token);
      return true;
    }
    return false;
  }

  Map<String, dynamic> toFirebaseObject() {
    if (tokens.length > maxTokens) {
      tokens.sublist(tokens.length - maxTokens);
    }
    return <String, dynamic> {
      UserPushTokensKeys.id: UserPushTokensKeys.pushTokens,
      UserPushTokensKeys.userId: userId,
      UserPushTokensKeys.username: username,
      UserPushTokensKeys.tokens: tokens
    };
  }

  bool updateFromUser(User user) {
    bool hasChange = false;
    if (username != user.username) {
      username = user.username;
      hasChange = true;
    }
    if (userId != user.id) {
      userId = user.id;
      hasChange = true;
    }
    return hasChange;
  }

  String removeCurrent() {
    if (tokens.isEmpty) {
      return null;
    }
    return tokens.removeLast();
  }
}
