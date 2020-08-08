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
  // * -------------------- Attributes --------------------

  String id = ''; // The id of the user
  String username = ''; // The username of the user
  String name = 'New User'; // The name to display
  List<String> chats = [];
  List<String> pushToken = [];
  String defaultPictureUrl;

  // ----------------------------------------

  PictureUrl _pictureUrl = PictureUrl();


  // * -------------------- Constructor --------------------

  User({
    this.id,
    this.username,
    this.name,
    this.chats,
    this.pushToken,
    this.defaultPictureUrl='',
  });

  // * -------------------- To Public --------------------

  // * -------------------- Link with firebase database  --------------------

  Map<String, Object> toFirebaseObject() {
    this.chats.sort();
    return {
      UserKeys.id: this.id,
      UserKeys.username: this.username,
      UserKeys.name: this.name,
      UserKeys.chats: this.chats,
      UserKeys.pushToken: this.pushToken,
      UserKeys.defaultPictureUrl: this.defaultPictureUrl,
    };
  }

  User.fromFirebaseObject(String id, Map firebaseObject) : id = id {
    if (firebaseObject != null) {
      this.username = firebaseObject.containsKey(UserKeys.username) ? firebaseObject[UserKeys.username] : '';
      this.name = firebaseObject.containsKey(UserKeys.name) ? firebaseObject[UserKeys.name] : '';
      this.chats = firebaseObject.containsKey(UserKeys.chats) ? List.from(firebaseObject[UserKeys.chats]) : [];
      this.pushToken = firebaseObject.containsKey(UserKeys.pushToken) ? List.from(firebaseObject[UserKeys.pushToken]) : [];
      this.defaultPictureUrl = firebaseObject.containsKey(UserKeys.defaultPictureUrl) ? firebaseObject[UserKeys.defaultPictureUrl] : '';
    }
  }

  bool get hasUsername {
    return this.username != null && this.username.isNotEmpty;
  }

  bool get hasNoUsername {
    return !this.hasUsername;
  }

  // * -------------------- Profile Picture --------------------

  String get picturePath {
    return 'users/${this.id}/picture';
  }

  Future<String> get pictureUrl async {
    if (this._pictureUrl.isEmpty && this._pictureUrl.hasUrl) {
      String url = await DatabaseFiles(path: this.picturePath).url;
      this._pictureUrl.url = url.isNotEmpty ? url: this.defaultPictureUrl;
      if (this._pictureUrl.isEmpty) {
        this._pictureUrl.hasUrl = false;
      }
    }
    return this._pictureUrl.getUrl(defaultAdorableAvatar: this.username ?? this.id);
  }

  Future<String> emptyPictureUrl ({bool reload=false}) async {
    this._pictureUrl.empty();
    if (reload) {
      return this.pictureUrl;
    }
    return this._pictureUrl.url;
  }
}


