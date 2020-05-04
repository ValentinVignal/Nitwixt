import 'package:flutter/material.dart';
import 'package:textwit/screens/chat/chat_messages.dart';

class ChatWidget extends StatefulWidget {

  final String id;

  ChatWidget({ this.id });

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('My Chat'),
        backgroundColor: Colors.blueGrey,
        leading: new IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
          Navigator.pop(context);
        }),
      ),
      body: ChatMessages(chatid: widget.id),
    );
  }
}



