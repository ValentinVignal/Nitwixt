import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:nitwixt/models/models.dart';
import 'package:nitwixt/services/cache/cache.dart';
import 'package:nitwixt/services/database/database_user.dart';
import 'package:nitwixt/services/database/database_files.dart';
import 'package:nitwixt/src/src.dart' as src;

import 'utils/picture_url.dart';

class ChatKeys {
  static const String id = 'id';
  static const String name = 'name';
  static const String members = 'members';
  static const String date = 'date';
}

class Chat extends Cachable<String> {
  Chat({
    this.id,
    this.name,
    this.members,
    this.date,
  }) {
    _pictureUrl.defaultAvatarId = (name != null && name.isNotEmpty) ? name : id;
  }

  Chat.fromFirebaseObject(this.id, Map<String, dynamic> firebaseObject) {
    if (firebaseObject != null) {
      name = firebaseObject.containsKey(ChatKeys.name) ? firebaseObject[ChatKeys.name].toString() : '';
      members = firebaseObject.containsKey(ChatKeys.members) ? List<String>.from(firebaseObject[ChatKeys.members] as List<dynamic>) : <String>[];
      members.sort();
      date = firebaseObject.containsKey(ChatKeys.date) ? firebaseObject[ChatKeys.date] as Timestamp : null;
    }
    _pictureUrl.defaultAvatarId = (name != null && name.isNotEmpty) ? name : id;
  }

  // * -------------------- Stored in Firebase --------------------
  String id; // The id of the chat
  String name; // The name of the chat
  List<String> members;
  Timestamp date;

  // ----------------------------------------

  final PictureUrl _pictureUrl = PictureUrl();

  @override
  List<Object> get props => <Object>[id, name, members];

  @override
  String get cacheId {
    return id;
  }

  // * -------------------- Constructed later Firebase --------------------
  Map<String, String> _nameToDisplay; // user id -> other user name (user for private chat with 2 persons)

  Map<String, Object> toFirebaseObject() {
    members.sort();
    return <String, dynamic>{
      ChatKeys.id: id,
      ChatKeys.name: name,
      ChatKeys.members: members,
      ChatKeys.date: date,
    };
  }

  // * -------------------- Name --------------------

  String _otherUserId(User user) {
    return members.where((String memberId) {
      return memberId != user.id;
    }).toList()[0];
  }

  Future<User> _otherUser(User user) async {
    final String otherUserId = _otherUserId(user);
    return await DatabaseUser(id: otherUserId).future;
  }

  Future<String> nameToDisplay(User user) async {
    if (!members.contains(user.id)) {
      // The user is not in this chat
      return '';
    } else {
      // the user is this chat
      if (name.isNotEmpty) {
        // The chat already has a name
        return name;
      } else {
        // The name is empty, we have to return something
        if (members.length == 1) {
          // Chat alone
          return '(@You) ${user.name}';
        } else if (members.length == 2) {
          // Private chat
          if (_nameToDisplay != null) {
            // Then no need to make a query
            return _nameToDisplay[user.id];
          } else {
            // Let's construct the object _nameToDisplay
            // First get the other user from database
            final User otherUser = await _otherUser(user);
            // construct map
            _nameToDisplay = <String, String>{};
            _nameToDisplay[user.id] = otherUser.name;
            _nameToDisplay[otherUser.id] = user.id;
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
    return 'chats/$id/picture';
  }

  Future<String> pictureUrl(User user) async {
    if (_pictureUrl.isEmpty && _pictureUrl.hasCustomUrl) {
      String url = await DatabaseFiles(path: picturePath).url;
      if (url.isEmpty) {
        if (members.length == 1) {
          // Chat alone
          url = await user.pictureUrl;
        } else if (members.length == 2) {
          // Private chat
          final User otherUser = await _otherUser(user);
          url = await otherUser.pictureUrl;
        }
      }
      _pictureUrl.setUrl(url);

      if (_pictureUrl.isEmpty) {
        _pictureUrl.hasCustomUrl = false;
      }
    }
    return _pictureUrl.url;
  }

  Future<String> emptyPictureUrl() async {
    _pictureUrl.empty();
    return await _pictureUrl.url;
  }

  bool equals(Chat chat) {
    return chat is Chat && chat != null && chat.id == id && chat.name == name && src.listEquals(chat.members, members);
  }

  @override
  Chat copy() {
    return Chat(
      id: id,
      name: name,
      members: List<String>.of(members),
    );
  }
}
