class PictureUrl {

  PictureUrl({String url = ''}) {
    _url = url;
  }

  String _url = '';
  bool _hasUrl = true;

  String get url {
    return _url;
  }

  set url(String url) {
    _url = url;
  }

  bool get isEmpty {
    return _url == null || _url.isEmpty;
  }

  bool get isNotEmpty {
    return url != null && _url.isNotEmpty;
  }

  bool get hasUrl {
    return _hasUrl;
  }

  set hasUrl(bool hasUrl) {
    _hasUrl = hasUrl;
    if (!_hasUrl) {
      _url = '';
    }
  }

  bool get hasNoUrl {
    return !_hasUrl;
  }

  set hasNoUrl(bool hasNoUrl) {
    _hasUrl = !hasNoUrl;
    if (!_hasUrl) {
      _url = '';
    }
  }

  void empty() {
    _hasUrl = true;
    _url = '';
  }

  static String adorableAvatar({String id = ''}) {
    return 'https://api.adorable.io/avatars/60/$id.png';
  }

  String getUrl({String defaultAdorableAvatar = ''}) {
    if (_url.isNotEmpty) {
      return _url;
    } else {
      return PictureUrl.adorableAvatar(id: defaultAdorableAvatar);
    }
  }
}
