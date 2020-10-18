import 'package:nitwixt/services/database/database.dart';
import 'utils/picture_url.dart';

mixin UserKeys {
  static const String id = 'id';
  static const String username = 'username';
  static const String name = 'name';
  static const String pushToken = 'pushToken';
  static const String defaultPictureUrl = 'defaultPictureUrl';

}

// Public user
class User {
  // * -------------------- Constructor --------------------

  User({
    this.id,
    this.username,
    this.name,
    this.pushToken,
    this.defaultPictureUrl='',
  }) {
    _pictureUrl.defaultAvatarId = username ?? id;
  }

  User.fromFirebaseObject(this.id, Map<String, dynamic> firebaseObject) {
    if (firebaseObject != null) {
      username = firebaseObject.containsKey(UserKeys.username) ? firebaseObject[UserKeys.username] as String : '';
      name = firebaseObject.containsKey(UserKeys.name) ? firebaseObject[UserKeys.name] as String : '';
      pushToken = firebaseObject.containsKey(UserKeys.pushToken) ? List<String>.from(firebaseObject[UserKeys.pushToken] as List<dynamic>) : <String>[];
      defaultPictureUrl = firebaseObject.containsKey(UserKeys.defaultPictureUrl) ? firebaseObject[UserKeys.defaultPictureUrl] as String : '';
    }
    _pictureUrl.defaultAvatarId = username ?? id;
  }


  // * -------------------- Attributes --------------------

  String id = ''; // The id of the user
  String username = ''; // The username of the user
  String name = 'New User'; // The name to display
//  List<String> chats = <String>[];
  List<String> pushToken = <String>[];
  String defaultPictureUrl;

  // ----------------------------------------

  final PictureUrl _pictureUrl = PictureUrl();


  // * -------------------- To Public --------------------

  // * -------------------- Link with firebase database  --------------------

  Map<String, Object> toFirebaseObject() {
//    chats.sort();
    return <String, dynamic>{
      UserKeys.id: id,
      UserKeys.username: username,
      UserKeys.name: name,
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
    if (_pictureUrl.isEmpty && _pictureUrl.hasCustomUrl) {
      final String url = await DatabaseFiles(path: picturePath).url;
      _pictureUrl.setUrl(url.isNotEmpty ? url : defaultPictureUrl);
    }
    return await _pictureUrl.url;
  }

  Future<String> emptyPictureUrl ({bool reload=false}) async {
    _pictureUrl.empty();
    if (reload) {
      return pictureUrl;
    }
    return await _pictureUrl.url;
  }
}


