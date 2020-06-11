
// Public user
class User {
  // * -------------------- Attributes --------------------

  String id = ''; // The id of the user
  String username = ''; // The username of the user
  String name = 'New User'; // The name to display
  List<String> chats = [];
  List<String> pushToken = [];

  // * -------------------- Constructor --------------------

  User({this.id, this.username, this.name, this.chats, this.pushToken});

  // * -------------------- To Public --------------------

  // * -------------------- Link with firebase database  --------------------

  Map<String, Object> toFirebaseObject() {
    this.chats.sort();
    return {
      'id': this.id,
      'username': this.username,
      'name': this.name,
      'chats': this.chats,
      'pushToken': this.pushToken,
    };

    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['id'] = this.id;
    firebaseObject['username'] = this.username;
    firebaseObject['name'] = this.name;
    firebaseObject['chats'] = this.chats;
    firebaseObject['pushToken'] = this.pushToken;

    return firebaseObject;
  }

  User.fromFirebaseObject(String id, Map firebaseObject) : id = id {
    if (firebaseObject != null) {
      this.username = firebaseObject.containsKey('username') ? firebaseObject['username'] : '';
      this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : '';
      this.chats = firebaseObject.containsKey('chats') ? List.from(firebaseObject['chats']) : [];
      this.pushToken = firebaseObject.containsKey('pushToken') ? List.from(firebaseObject['pushToken']) : [];
    }
  }

  bool get hasUsername {
    return this.username == null || this.username.isEmpty;
  }
}
