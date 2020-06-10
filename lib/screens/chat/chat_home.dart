import 'package:flutter/material.dart';
import 'package:nitwixt/screens/chat/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/screens/chat/chat_messages.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/chat/chat_info.dart';

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
//        title: Text(chat.nameToDisplay(user)),
//        title: Text(chat.name),
        title: FutureBuilder<String>(
          future: chat.nameToDisplay(user),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                '...',
                style: TextStyle(color: Colors.grey, fontSize: 18.0),
              );
            } else {
              if (snapshot.hasError) {
                return Text(
                  'Could not display name',
                  style: TextStyle(color: Colors.red, fontSize: 18.0),
                );
              } else {
                return Text(snapshot.data, style: TextStyle(color: Colors.white, fontSize: 18.0));
              }
            }
          },
        ),
        backgroundColor: Colors.blueGrey[800],
        leading: new IconButton(
            icon: Icon(Icons.arrow_back_ios),
            onPressed: () {
              Navigator.pop(context);
            }),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatProvider(
                    id: chat.id,
                    child: ChatInfo(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ChatMessages(),
    );
  }
}
