import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:nitwixt/services/database/database.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/home/chat_tile.dart';

class ChatsCache {
  ChatsCache();

  final Map<String, models.Chat> chats = <String, models.Chat>{};
  final Map<String, Widget> widgets = <String, Widget>{};

  bool get isEmpty => chats.isEmpty;

  bool get isNotEmpty => chats.isNotEmpty;

  void addChat(models.Chat chat, Widget widget) {
    if (!chats.containsKey(chat.id) || chats[chat.id] != chat) {
      print('is different for ${chat.name}');
      chats[chat.id] = chat;
      widgets[chat.id] = widget;
    }
  }

  void addChatList(List<models.Chat> chatList, List<Widget> widgetList) {
    for (int i = 0; i < chatList.length; i++) {
      addChat(chatList[i], widgetList[i]);
    }
  }

  List<models.Chat> get chatList {
    final List<models.Chat> list = chats.values.toList();
    list.sort((models.Chat chat1, models.Chat chat2) {
      return chat1.id.compareTo(chat2.id);
    });
    return list;
  }
}

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  int _nbChats = 8;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<GlobalKey<ChatTileState>> chatTileStateList;
  final ChatsCache _chatsCache = ChatsCache();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    setState(() {});
//    if (chatTileStateList != null) {
//      for (final GlobalKey<ChatTileState> chatTileState in chatTileStateList) {
//        chatTileState.currentState.refresh();
//      }
//    }
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    setState(() {
      _nbChats += 4;
    });
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);

    return StreamBuilder<List<models.Chat>>(
      stream: DatabaseChat.getChatList(userid: user.id, limit: _nbChats),
      builder: (BuildContext context, AsyncSnapshot<List<models.Chat>> snapshot) {
        if (snapshot.hasData) {
          _chatsCache.addChatList(snapshot.data, snapshot.data.map((models.Chat chat) {
            return ChatTile(
              chat: chat,
            );
          }).toList());
        }
        if (!snapshot.hasData) {
          return LoadingCircle();
        } else {
          final List<models.Chat> chatList = snapshot.data;
          chatTileStateList = chatList.map((models.Chat element) {
            return GlobalKey<ChatTileState>();
          }).toList();
          if (chatList.isEmpty) {
            // User doesn't have chats yet
            const TextStyle textStyle = TextStyle(color: Colors.white, fontSize: 15.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(text: 'You don\'t have any chat yet...', style: textStyle),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15.0),
                    RichText(
                      text: const TextSpan(
                        children: <InlineSpan>[
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
            return SmartRefresher(
              enablePullDown: true,
              enablePullUp: true,
              header: const ClassicHeader(),
              controller: _refreshController,
//              scrollController: _scrollController,
              onRefresh: _onRefresh,
              onLoading: _onLoading,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: chatList.length,
                itemBuilder: (BuildContext context, int index) {
                  final models.Chat chat = _chatsCache.chatList[index];
                  return _chatsCache.widgets[chat.id];
//                  return ChatTile(chat: chatList[index], key: chatTileStateList[index]);
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
