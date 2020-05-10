import 'package:flutter/material.dart';
import 'package:textwit/models/models.dart' as models;
import 'package:textwit/screens/chat/chat_provider.dart';

class ChatTile extends StatelessWidget {
  final models.ChatPublic chat;

  ChatTile({this.chat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(Icons.chat_bubble, color: Colors.blue[800], size: 50.0,),
            SizedBox(width: 20.0,),
            Text(chat.name, style: TextStyle(color: Colors.white, fontSize: 20.0)),
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal:20.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.blueGrey[800]),
          )
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatProvider(id: chat.id)),
          );
      },
    );
  }
}
