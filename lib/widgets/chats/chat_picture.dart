import 'package:flutter/material.dart';
import 'package:nitwixt/widgets/profile_picture.dart';
import 'package:nitwixt/models/models.dart' as models;

class ChatPicture extends StatelessWidget {

  const ChatPicture({
    @required this.chat,
    @required this.user,
    this.size = 15.0,
  }) : super();

  final models.Chat chat;
  final models.User user;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ProfilePicture(
      urlAsync: chat.pictureUrl(user),
      size: size,
      defaultImage: Image.asset('assets/images/chatDefault.png', height: 50.0, width: 50.0,),
    );
  }
}
