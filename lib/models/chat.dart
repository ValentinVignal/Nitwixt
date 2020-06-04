import 'package:nitwixt/models/models.dart';
import 'package:nitwixt/models/user_public.dart';
import 'package:nitwixt/models/chat_public.dart';

class Chat {
  String id;    // The id of the chat
  String name;      // The name of the chat
  List<String> members;

  Chat({ this.id, this.name, this.members});

  ChatPublic toChatPublic({User user}) {
    if (user == null) {
      return ChatPublic(id: this.id, name: this.name);
    } else {
      return ChatPublic(
        id: this.id,
        name: nameToDisplay(user),
      );
    }
  }

  Map<String, Object> toFirebaseObject() {
    Map<String, Object> firebaseObject = Map<String, Object>();

    firebaseObject['name'] = this.name;
    firebaseObject['members'] = this.members;
    firebaseObject['id'] = this.id;

    return firebaseObject;
  }

  Chat.fromFirebaseObject(String id, Map firebaseObject):
      id = id {
    this.name = firebaseObject.containsKey('name') ? firebaseObject['name'] : 'Unkown name';
    this.members = firebaseObject.containsKey('members') ? firebaseObject['members'] : [];
  }

  String nameToDisplay(User user) {
    if(!this.members.contains(user.id)) {
      // The user is not in this chat
      return null;
    } else {
      // the user is this chat
      if (this.name.isNotEmpty) {
        // The chat already has a name
        return this.name;
      } else {
        // The name is empty, we have to return something
        if (this.members.length == 1) {
          // Chat alone
          return '(@You) ${user.name}';
        } else if (this.members.length == 2) {
          // Private chat
          return 'Private Chat';
//          return this.members.values.where((UserPublic member) {
//            return member.id != user.id;
//          }).toList()[0].name;
        } else {
          // It is a chat with more than 2 people
          return 'Group Chat';
        }
      }
    }

  }

}

