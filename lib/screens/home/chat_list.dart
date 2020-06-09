import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
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
    return StreamBuilder<List<models.Chat>>(
      stream: DatabaseChat.getChatList(chatIdList: user.chats, limit: _nbChats),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        } else {
          List<models.Chat> chatList = snapshot.data;
          if (chatList.isEmpty) {
            // User doesn't have chats yet
            TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 15.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'You don\'t have any chat yet...', style: textStyle),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 15.0),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(text: 'Press the ', style: textStyle),
                          WidgetSpan(
                            child: Icon(
                              Icons.add,
                              color: Colors.blue,
                              size: 20.0,
                            ),
                          ),
                          TextSpan(text: ' to create a chat', style: textStyle),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            );
          } else {
            // User have chats
            double height = MediaQuery.of(context).size.height;
            return SizedBox(
              height: height,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  return ChatTile(chat: chatList[index]);
                },
              ),
            );
          }
        }
      },
    );
  }
}
