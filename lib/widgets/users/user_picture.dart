import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/profile_picture.dart';

class UserPicture extends StatelessWidget {
  final models.User user;
  final double size;

  UserPicture({
    @required this.user,
    this.size,
  }): super();

  @override
  Widget build(BuildContext context) {
    return ProfilePicture(
      urlAsync: user.pictureUrl,
//      path: user.picturePath,
      size: this.size,
      defaultImage: Image.asset('assets/images/defaultProfilePicture.png'),
    );
  }
}
