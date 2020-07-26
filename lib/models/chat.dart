import 'package:nitwixt/models/models.dart';
import 'package:nitwixt/services/database/database_user.dart';
import 'package:nitwixt/services/database/database_files.dart';
import 'utils/picture_url.dart';

class ChatKeys {
  static final String id = 'id';
  static final String name = 'name';
  static final String members = 'members';
}

class Chat {
  // * -------------------- Stored in Firebase --------------------
  String id; // The id of the chat
  String name; // The name of the chat
  List<String> members;

  // ----------------------------------------

  PictureUrl _pictureUrl = PictureUrl();


  // * -------------------- Constructed later Firebase --------------------
  Map<String, String> _nameToDisplay; // user id -> other user name (user for private chat with 2 persons)

  Chat({
    this.id,
    this.name,
    this.members,
  });

  Map<String, Object> toFirebaseObject() {
    this.members.sort();
    return {
      ChatKeys.id: this.id,
      ChatKeys.name: this.name,
      ChatKeys.members: this.members,
    };
  }

  Chat.fromFirebaseObject(String id, Map firebaseObject) : id = id {
    if (firebaseObject != null) {
      this.name = firebaseObject.containsKey(ChatKeys.name) ? firebaseObject[ChatKeys.name] : 'Unkown name';
      this.members = firebaseObject.containsKey(ChatKeys.members) ? List.from(firebaseObject[ChatKeys.members]) : [];
      this.members.sort();
    }
  }

  // * -------------------- Name --------------------

  String _otherUserId(User user) {
    return this.members.where((String memberId) {
      return memberId != user.id;
    }).toList()[0];
  }

  Future<User> _otherUser(User user) async {
    String otherUserId = this._otherUserId(user);
    User otherUser = await DatabaseUser(id: otherUserId).userFuture;
    return otherUser;
  }

  Future<String> nameToDisplay(User user) async {
    if (!this.members.contains(user.id)) {
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
          if (this._nameToDisplay != null) {
            // Then no need to make a query
            return this._nameToDisplay[user.id];
          } else {
            // Let's construct the object _nameToDisplay
            // First get the other user from database
            User otherUser = await this._otherUser(user);
            // construct map
            this._nameToDisplay = new Map();
            this._nameToDisplay[user.id] = otherUser.name;
            this._nameToDisplay[otherUser.id] = user.id;
            return otherUser.name;
          }
        } else {
          // It is a chat with more than 2 people
          return 'Group Chat';
        }
      }
    }
  }

  // * -------------------- Profile Picture --------------------

  String get picturePath {
    return 'chats/${this.id}/picture';
  }

  Future<String> pictureUrl(User user) async {
    print('chatname ${this.name} - ${this._pictureUrl.isEmpty} - ${this._pictureUrl.url}');
    if (this._pictureUrl.isEmpty && this._pictureUrl.hasUrl) {
      print('in if');
      this._pictureUrl.url = await DatabaseFiles(path: this.picturePath).url;
      if (this._pictureUrl.isEmpty) {
        if(this.members.length == 1) {
          // Chat alone
          this._pictureUrl.url = await user.pictureUrl;
        } else if (this.members.length == 2) {
          // Private chat
          User otherUser = await this._otherUser(user);
          this._pictureUrl.url = await otherUser.pictureUrl;
        }
      }
      if (this._pictureUrl.isEmpty) {
        this._pictureUrl.hasUrl = false;
      }
    }
    print('after if ${this._pictureUrl.url}');
    return this._pictureUrl.url;
  }

  String emptyPictureUrl () {
    this._pictureUrl.empty();
    return this._pictureUrl.url;
  }
}
