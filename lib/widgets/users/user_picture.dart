import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/profile_picture.dart';

class UserPicture extends StatelessWidget {
  const UserPicture({
    @required this.user,
    this.size,
  }): super();

  final models.User user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ProfilePicture(
      urlAsync: user.pictureUrl,
//      path: user.picturePath,
      size: size,
      defaultImage: Image.asset('assets/images/defaultProfilePicture.png'),
    );
  }
}
