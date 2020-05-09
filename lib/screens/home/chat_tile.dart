import 'package:flutter/material.dart';
import 'package:textwit/models/models.dart' as models;
import 'package:textwit/screens/chat/chat_provider.dart';

class ChatTile extends StatelessWidget {
  final models.ChatPublic chat;

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
          subtitle: Text(chat.id),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatProvider(id: chat.id)),
            );
          },
        ),
      ),
    );
  }
}
