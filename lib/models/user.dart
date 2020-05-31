import 'package:nitwixt/models/chat_public.dart';
import 'package:nitwixt/models/user_public.dart';

// Public user
class User {
  // * -------------------- Attributes --------------------

  final String id; // The id of the user
  String username = ''; // The username of the user
  String name = 'New User'; // The name to display
  Map<String, ChatPublic> chats = new Map(); // The list of chats of the user
  String pushToken;

  // * -------------------- Constructor --------------------

  User({this.id, this.username, this.name, this.chats, this.pushToken});

  // * -------------------- To Public --------------------

  UserPublic toUserPublic() {
    return UserPublic(id: this.id, name: this.name, username: this.username);
  }

  // * -------------------- Link with firebase database  --------------------

  Map<String, Object> toFirebaseObject() {
    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['username'] = this.username;
    firebaseObject['name'] = this.name;
    Map<String, Object> chatMap = Map<String, Object>();
    this.chats.forEach((String chatid, ChatPublic chat) {
      chatMap[chatid] = chat.toFirebaseObject();
    });
    firebaseObject['chats'] = chatMap;
    firebaseObject['pushToken'] = this.pushToken;

    return firebaseObject;
  }

  User.fromFirebaseObject(String id, Map firebaseObject) : id = id {
    if (firebaseObject != null) {
      this.username = firebaseObject.containsKey('username') ? firebaseObject['username'] : '';
      this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : '';
      this.chats = firebaseObject.containsKey('chats')
          ? firebaseObject['chats'].map<String, ChatPublic>((key, chat) {
              String key_ = key;
              return MapEntry(key_, ChatPublic.fromFirebaseObject(key, chat));
            })
          : Map<String, ChatPublic>();
    }
    this.pushToken = firebaseObject.containsKey('pushToken') ? firebaseObject['pushToken'] : '';
  }

  User.empty() : id = '';

  bool isEmpty() {
    return this.username == null || this.username.isEmpty;
  }
}
