import 'package:http/http.dart' as http;

class PictureUrl {
  PictureUrl({
    this.defaultAvatarId = '',
    String url,
  }) {
    _url = url ?? '';
    if (url != null) {
      _hasCustomUrl = url.isNotEmpty;
    }
  }

  String defaultAvatarId;
  String _url = '';
  bool _hasCustomUrl = true;      // If the user managed to give a custom non empty URL
  String _defaultUrl = '';
  bool _hasLoadedDefault = false;   // If the default URL has been loaded already

  Future<String> get url async {
    if (_url != null && _url.isNotEmpty) {
      return _url;
    }
    if (_defaultUrl != null && _defaultUrl.isNotEmpty) {
      return _defaultUrl;
    }
    if (!_hasLoadedDefault) {
      await loadDefaultUrl();
    }
    return _defaultUrl;
  }

  void setUrl(String url){
    _url = url;
    _hasCustomUrl =  url == null || url.isNotEmpty;
  }

  bool get isEmpty {
    return _url == null || _url.isEmpty;
  }

  bool get isNotEmpty {
    return _url != null && _url.isNotEmpty;
  }

  bool get hasCustomUrl {
    return _hasCustomUrl;
  }

  set hasCustomUrl(bool hasCustomUrl) {
    _hasCustomUrl = hasCustomUrl;
    if (!_hasCustomUrl) {
      _url = '';
    }
  }

  bool get hasNoCustomUrl {
    return !_hasCustomUrl;
  }

  set hasNoCustomUrl(bool hasNoUrl) {
    _hasCustomUrl = !hasNoUrl;
    if (!_hasCustomUrl) {
      _url = '';
    }
  }

  void empty() {
    _hasCustomUrl = true;
    _url = '';
  }

  static List<String> defaultUrls({String id = ''}) {
    const int size = 60;
    return <String>[
      'https://api.hello-avatar.com/adorables/$size/$id',
      'https://avatars.dicebear.com/api/bottts/$id.svg?h=$size&w=$size',
      'https://avatars.dicebear.com/api/gridy/$id.svg?h=$size&w=$size',
      'https://avatars.dicebear.com/api/identicon/$id.svg?h=$size&w=$size',
      'https://avatars.dicebear.com/api/initials/$id.svg?h=$size&w=$size',
      'https://avatars.dicebear.com/api/jdenticon/$id.svg?h=$size&w=$size',
      'https://api.adorable.io/avatars/$size/$id', // Not supposed to be maintained anymore
    ];
  }

  Future<String> loadDefaultUrl({String avatarId=''}) async {
    if (_hasLoadedDefault) {
      return _defaultUrl;
    }
    if (avatarId != null && avatarId.isNotEmpty) {
      defaultAvatarId = avatarId;
    }
    for (final String url in defaultUrls(id: defaultAvatarId)) {
      final http.Response response = await http.head(url);
      if (<int>[200, 304].contains(response.statusCode)) {
        _defaultUrl = url;
        break;
      }
    }
    _hasLoadedDefault = true;

    return _defaultUrl;

  }
}
