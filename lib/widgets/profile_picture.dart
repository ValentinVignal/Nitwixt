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
        if (asyncSnapshot.connectionState == ConnectionState.done && !asyncSnapshot.hasError) {
          if (asyncSnapshot.data != null) {
            return CircleAvatar(
              radius: size,
              backgroundImage: asyncSnapshot.data.image,
            );
          } else {
            return const SizedBox.shrink();
          }
        } else {
          return LoadingCircle(size: 1.5 * size);
        }
      },
    );
  }
}
