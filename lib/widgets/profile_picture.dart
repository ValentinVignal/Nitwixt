import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';
import 'loading/loading.dart';

class ProfilePicture extends StatelessWidget {
  ProfilePicture({
    this.path,
    this.url,
    this.urlAsync,
    this.size=15.0,
    this.defaultImage,
  }) : super() {
//    assert((path == null) != (url == null));
    size ??= 15.0;
  }

  double size;
  final String path;
  final String url;
  final Future<String> urlAsync;
  final Image defaultImage;
  String _url;


  Future<void> _getUrl() async {
    if (_url == null) {
      if (url != null) {
        _url = url;
      } else if (path != null) {
        _url = await DatabaseFiles(path: path).url;
      } else if (urlAsync != null) {
        _url = await urlAsync;
      }
    }
  }

  Future<Image> _getImage() async {
    await _getUrl();
    return DatabaseFiles.imageFromUrl(
      _url,
      defaultImage: defaultImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: _getImage(),
      builder: (BuildContext buildContext, AsyncSnapshot<Image> asyncSnapshot) {
        ImageProvider backgroundImage;
        Color backgroundColor = Colors.black;
        if (asyncSnapshot.connectionState == ConnectionState.done && !asyncSnapshot.hasError) {
          if (asyncSnapshot.data != null) {
            backgroundImage = asyncSnapshot.data.image;
            backgroundColor = null;
          }
        }
        return CircleAvatar(
          backgroundColor: backgroundColor,
          radius: size,
          backgroundImage: backgroundImage,
        );
      },
    );
  }
}
