import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/home/chat_tile.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {

    final models.User user = Provider.of<models.User>(context) ?? [];
    final List<models.ChatPublic> chats = user.chats.values.toList();

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return ChatTile(chat: chats[index]);
      },
    );
  }
}
