import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';
import 'loading/loading.dart';

class ProfilePicture extends StatelessWidget {
  double size;
  final String path;
  final String url;
  final Future<String> urlAsync;
  final Image defaultImage;
  String _url;

  ProfilePicture({
    this.path,
    this.url,
    this.urlAsync,
    this.size=15.0,
    this.defaultImage,
  }) : super() {
//    assert((path == null) != (url == null));
    if (size == null) {
      this.size = 15.0;
    }
  }

  Future _getUrl() async {
    if (this._url == null) {
      if (this.url != null) {
        this._url = url;
      } else if (path != null) {
        this._url = await DatabaseFiles(path: path).url;
      } else if (urlAsync != null) {
        this._url = await urlAsync;
      }
    }
  }

  Future<Image> _getImage() async {
    await this._getUrl();
    return DatabaseFiles.imageFromUrl(
      this._url,
      defaultImage: this.defaultImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: _getImage(),
      builder: (BuildContext buildContext, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done && !asyncSnapshot.hasError) {
          print('size');
          print(size);
          return CircleAvatar(
            radius: this.size,
            backgroundImage: asyncSnapshot.data.image,
          );
        } else {
          return LoadingCircle(size: 1.5 * this.size);
        }
      },
    );
  }
}
