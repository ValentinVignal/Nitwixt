// Textwit user
class UserAuth {
  final String id;

  UserAuth({this.id});
}

// Public user
class User {
  final String id;
  final String username;
  String name;
  Map<String, UserChat> chats = new Map();

  User({this.id, this.username, this.name, this.chats});
}

// Information of a chat in a user profile
class UserChat {
  final String id;
  String name;

  UserChat({ this.id, this.name });
}


// From coffee tutorial
class UserData {
  final String uid;
  final String name;
  final String sugars;
  final int strength;

  UserData({this.uid, this.name, this.sugars, this.strength});
}
