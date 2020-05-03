import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/chat.dart';
import 'package:textwit/models/user.dart';
import 'package:textwit/screens/chats/chat_tile.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  Widget build(BuildContext context) {

    final chats = Provider.of<List<UserChat>>(context) ?? [];

    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        return ChatTile(chat: chats[index]);
      },
    );
  }
}
