import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';
import 'package:nitwixt/shared/loading.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/home/chat_tile.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  int _nbChats = 8;
  ScrollController _scrollController;

  _scrollListener() {
    if (_scrollController.position.maxScrollExtent == _scrollController.position.pixels) {
      setState(() {
        _nbChats += 4;
      });
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    final models.User user = Provider.of<models.User>(context) ?? [];
//    final List<models.ChatPublic> chats = user.chats.values.toList();

    return StreamBuilder<List<models.Chat>>(
      stream: DatabaseChat.getChatList(chatIdList: user.chats, limit: _nbChats),
      builder: (context, snapshot) {
        print('snapshot data ${snapshot.hasData}');
        if (!snapshot.hasData) {
          return Loading();
        } else {
          List<models.Chat> chatList = snapshot.data;
          double height = MediaQuery.of(context).size.height;

          return SizedBox(
            height: height,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: chatList.length,
                    itemBuilder: (context, index) {
                      models.Chat chat = chatList[index];
                      return Text('Chat ${chat.name}, $index');
                    },
                  ),
                )
              ],
            )
          );
        }
      },
    );
//    return ListView.builder(
//      itemCount: chats.length,
//      itemBuilder: (context, index) {
//        return ChatTile(chat: chats[index]);
//      },
//    );
  }
}
