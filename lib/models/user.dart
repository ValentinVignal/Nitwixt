import 'package:textwit/models/chat_public.dart';
import 'package:textwit/models/user_public.dart';

// Public user
class User {
  final String id;    // The id of the user
  final String username;    // The username of the user
  String name;      // The name to display
  Map<String, ChatPublic> chats = new Map();    // The list of chats of the user

  User({this.id, this.username, this.name, this.chats});

  UserPublic toUserPublic() {
    return UserPublic(id: this.id, name: this.name, username: this.username);
  }

  Map<String, Object> toFirebaseObject() {

    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['id'] = this.id;
    firebaseObject['username'] = this.username;
    firebaseObject['name'] = this.name;
    Map<String, Object> chatMap = Map<String, Object>();
    this.chats.forEach((String chatid, ChatPublic chat) {
      chatMap[chatid] = chat.toFirebaseObject();
    });
    firebaseObject['chats'] = chatMap;

    return firebaseObject;
  }

  User.fromFirebaseObject(Map firebaseObject):
      id = firebaseObject['id'],
      username = firebaseObject['username'] {
    this.name = firebaseObject.containsKey('name') ? firebaseObject['key'] : 'Unknown name';
    this.chats = firebaseObject.containsKey('chats') ?
        firebaseObject['chats'].map((String key, Map chat) {
          return MapEntry(key, ChatPublic.fromFirebaseObject(chat));
        }):
        Map<String, ChatPublic>();
  }

}


// --------------------

// From coffee tutorial
class UserData {
  final String uid;
  final String name;
  final String sugars;
  final int strength;

  UserData({this.uid, this.name, this.sugars, this.strength});
}
