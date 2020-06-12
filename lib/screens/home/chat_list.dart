import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/home/chat_tile.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  int _nbChats = 8;
  RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<GlobalKey<ChatTileState>> chatTileStateList;

  @override
  void dispose() {
    _refreshController.dispose();
  }

  void _onRefresh() async {
    setState(() {});
    if (chatTileStateList != null) {
      chatTileStateList.forEach((chatTileState){
        chatTileState.currentState.refresh();
      });
    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      _nbChats += 4;
    });
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context) ?? [];

    return StreamBuilder<List<models.Chat>>(
      stream: DatabaseChat.getChatList(chatIdList: user.chats, limit: _nbChats),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingCircle();
        } else {
          List<models.Chat> chatList = snapshot.data;
          chatTileStateList = chatList.map((element) {
            return GlobalKey<ChatTileState>();
          }).toList();
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
            return SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: ClassicHeader(
              ),
              controller: _refreshController,
//              scrollController: _scrollController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
                itemCount: chatList.length,
                itemBuilder: (context, index) {
                  return ChatTile(chat: chatList[index], key: chatTileStateList[index]);
//                  return ChatTile(chat: chatList[index]);
                },
              ),
            );
          }
        }
      },
    );
  }
}
