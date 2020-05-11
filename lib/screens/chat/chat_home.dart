import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/screens/chat/chat_messages.dart';
import 'package:nitwixt/models/models.dart' as models;

class ChatHome extends StatefulWidget {

  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  @override
  Widget build(BuildContext context) {

    final models.Chat chat = Provider.of<models.Chat>(context);
    final models.User user = Provider.of<models.User>(context);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(chat.nameToDisplay(user)),
        backgroundColor: Colors.blueGrey[800],
        leading: new IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {
          Navigator.pop(context);
        }),
      ),
      body: ChatMessages(),
    );
  }
}



