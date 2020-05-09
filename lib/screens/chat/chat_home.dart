import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/screens/chat/chat_messages.dart';
import 'package:textwit/models/models.dart' as models;

class ChatHome extends StatefulWidget {

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  @override
  Widget build(BuildContext context) {

    final models.Chat chat = Provider.of<models.Chat>(context);

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('My Chat'),
        backgroundColor: Colors.blueGrey,
        leading: new IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
          Navigator.pop(context);
        }),
      ),
      body: ChatMessages(),
    );
  }
}



