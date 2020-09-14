import 'package:nitwixt/services/database/database.dart';
import 'utils/picture_url.dart';

class UserKeys {
  static final String id = 'id';
  static final String username = 'username';
  static final String name = 'name';
  static final String pushToken = 'pushToken';
  static final String chats = 'chats';
  static final String defaultPictureUrl = 'defaultPictureUrl';

}

// Public user
class User {
  // * -------------------- Constructor --------------------

  User({
    this.id,
    this.username,
    this.name,
    this.chats,
    this.pushToken,
    this.defaultPictureUrl='',
  });

  User.fromFirebaseObject(this.id, Map<String, dynamic> firebaseObject) {
    if (firebaseObject != null) {
      username = firebaseObject.containsKey(UserKeys.username) ? firebaseObject[UserKeys.username] as String : '';
      name = firebaseObject.containsKey(UserKeys.name) ? firebaseObject[UserKeys.name] as String : '';
      chats = firebaseObject.containsKey(UserKeys.chats) ? List<String>.from(firebaseObject[UserKeys.chats] as Iterable<dynamic>) : <String>[];
      pushToken = firebaseObject.containsKey(UserKeys.pushToken) ? List<String>.from(firebaseObject[UserKeys.pushToken] as Iterable<dynamic>) : <String>[];
      defaultPictureUrl = firebaseObject.containsKey(UserKeys.defaultPictureUrl) ? firebaseObject[UserKeys.defaultPictureUrl] as String : '';
    }
  }


  // * -------------------- Attributes --------------------

  String id = ''; // The id of the user
  String username = ''; // The username of the user
  String name = 'New User'; // The name to display
  List<String> chats = <String>[];
  List<String> pushToken = <String>[];
  String defaultPictureUrl;

  // ----------------------------------------

  final PictureUrl _pictureUrl = PictureUrl();


  // * -------------------- To Public --------------------

  // * -------------------- Link with firebase database  --------------------

  Map<String, Object> toFirebaseObject() {
    chats.sort();
    return <String, dynamic>{
      UserKeys.id: id,
      UserKeys.username: username,
      UserKeys.name: name,
      UserKeys.chats: chats,
      UserKeys.pushToken: pushToken,
      UserKeys.defaultPictureUrl: defaultPictureUrl,
    };
  }

  bool get hasUsername {
    return username != null && username.isNotEmpty;
  }

  bool get hasNoUsername {
    return !hasUsername;
  }

  // * -------------------- Profile Picture --------------------

  String get picturePath {
    return 'users/$id/picture';
  }

  Future<String> get pictureUrl async {
    if (_pictureUrl.isEmpty && _pictureUrl.hasUrl) {
      final String url = await DatabaseFiles(path: picturePath).url;
      _pictureUrl.url = url.isNotEmpty ? url: defaultPictureUrl;
      if (_pictureUrl.isEmpty) {
        _pictureUrl.hasUrl = false;
      }
    }
    return _pictureUrl.getUrl(defaultAdorableAvatar: username ?? id);
  }

  Future<String> emptyPictureUrl ({bool reload=false}) async {
    _pictureUrl.empty();
    if (reload) {
      return pictureUrl;
    }
    return _pictureUrl.url;
  }
}


