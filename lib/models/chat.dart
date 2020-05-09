import 'package:textwit/models/user_public.dart';
import 'package:textwit/models/chat_public.dart';

class Chat {
  final String id;    // The id of the chat
  String name;      // The name of the chat
  Map<String, UserPublic> members;   // The Map of the members

  Chat({ this.id, this.name, this.members});

  ChatPublic toChatPublic() {
    return ChatPublic(id: this.id, name: this.name);
  }

  Map<String, Object> toFirebaseObject() {
    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['name'] = this.name;
    Map members = this.members.map((String key, UserPublic user) {
      return MapEntry(key, user.toFirebaseObject());
    });
    firebaseObject['members'] = members;

    return firebaseObject;
  }

  Chat.fromFirebaseObject(String id, Map firebaseObject):
      id = id {
    this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : 'Unkown name';
    this.members = firebaseObject.containsKey('members') ?
        firebaseObject['members'].map<String, UserPublic>((key, userObject) {
          String key_ = key;
          return MapEntry(key_, UserPublic.fromFirebaseObject(key, userObject));
        }) :
        Map<String, UserPublic>();
  }

}

