import 'package:flutter/material.dart';
import 'package:textwit/models/user.dart';
import 'package:textwit/screens/chat/chat.dart';

class ChatTile extends StatelessWidget {
  final UserChat chat;

  ChatTile({this.chat});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundColor: Colors.blue,
            backgroundImage: AssetImage('assets/images/message.png'),
          ),
          title: Text(chat.name),
          subtitle: Text('Speak with your friends !'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatWidget(id: chat.id)),
            );
          },
        ),
      ),
    );
  }
}
