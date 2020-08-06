class PictureUrl {
  String _url = '';
  bool _hasUrl = true;

  PictureUrl({String url = ''}) {
    this._url = url;
  }

  String get url {
    return this._url;
  }

  set url(String url) {
    this._url = url;
  }

  bool get isEmpty {
    return this._url == null || this._url.isEmpty;
  }

  bool get isNotEmpty {
    return this.url != null && this._url.isNotEmpty;
  }

  bool get hasUrl {
    return this._hasUrl;
  }

  set hasUrl(bool hasUrl) {
    this._hasUrl = hasUrl;
    if (!this._hasUrl) {
      this._url = '';
    }
  }

  bool get hasNoUrl {
    return !this._hasUrl;
  }

  set hasNoUrl(bool hasNoUrl) {
    this._hasUrl = !hasNoUrl;
    if (!this._hasUrl) {
      this._url = '';
    }
  }

  void empty() {
    this._hasUrl = true;
    this._url = '';
  }

  static String adorableAvatar({String id = ''}) {
    return 'https://api.adorable.io/avatars/60/$id.png';
  }

  String getUrl({String defaultAdorableAvatar = ''}) {
    if (_url.isNotEmpty) {
      return this._url;
    } else {
      return PictureUrl.adorableAvatar(id: defaultAdorableAvatar);
    }
  }
}
