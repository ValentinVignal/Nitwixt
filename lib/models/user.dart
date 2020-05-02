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

  User({this.id, this.username, this.name});
}

// Private user
class UserSetting {
  final String id;

  UserSetting({this.id});
}

// From coffee tutorial
class UserData {
  final String uid;
  final String name;
  final String sugars;
  final int strength;

  UserData({this.uid, this.name, this.sugars, this.strength});
}
