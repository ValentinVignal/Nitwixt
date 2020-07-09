import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';
import 'loading/loading.dart';

class ProfilePicture extends StatelessWidget {
  final double size;
  final String path;
  final String url;
  final Future<String> urlAsync;
  String _url;

  ProfilePicture({
    this.path,
    this.url,
    this.urlAsync,
    this.size = 15.0
  }) : super() {
//    assert((path == null) != (url == null));
  }

  Future _getUrl() async {
    if (this._url == null) {
      if (this.url != null) {
        this._url = url;
      } else if (path != null) {
        this._url = await DatabaseFile(path: path).url;
      } else if (urlAsync != null) {
        this._url = await urlAsync;
      }
    }
  }

  Future<Image> _getImage() async {
    await this._getUrl();
    return DatabaseFile.imageFromUrl(this._url);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: _getImage(),
      builder: (BuildContext buildContext, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done && ! asyncSnapshot.hasError) {
          return CircleAvatar(
            radius: this.size,
            backgroundImage: asyncSnapshot.data.image,
          );
        } else {
          print('ProfilePicture error');
          print(asyncSnapshot.error);
          return LoadingCircle(size: 1.5 * this.size);
        }
      },
    );
  }
}
