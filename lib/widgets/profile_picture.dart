import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';
import 'loading/loading.dart';

class ProfilePicture extends StatelessWidget {
  final double size;
  final String path;

  ProfilePicture({
    @required this.path,
    this.size = 15.0
  }) : super();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Image>(
      future: DatabaseFile(path: this.path).image,
      builder: (BuildContext buildContext, AsyncSnapshot asyncSnapshot) {
        if (asyncSnapshot.connectionState == ConnectionState.done && ! asyncSnapshot.hasError) {
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
