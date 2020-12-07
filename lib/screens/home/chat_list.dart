import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/services/cache/cache.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:nitwixt/services/database/database.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/home/chat_tile.dart';

class ChatList extends StatefulWidget {
  @override
  _ChatListState createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  int _nbChats = 8;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<GlobalKey<ChatTileState>> chatTileStateList;

  // final ChatsCache _chatsCache = ChatsCache();
  final CachedWidgets<String, models.Chat> chatsCache = CachedWidgets<String, models.Chat>();

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    setState(() {
      chatsCache.clear();
      _nbChats = 8;
    });
    _refreshController.refreshCompleted();
  }

  void _onLoading() {
    setState(() {
      _nbChats += 8;
    });
    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);

    final CachedStreamList<String, models.Chat> cachedChatList = CachedStreamList<String, models.Chat>(
      DatabaseChatMixin.getChatList(userid: user.id, limit: _nbChats),
    );

    return StreamBuilder<List<models.Chat>>(
      // stream: DatabaseChatMixin.getChatList(userid: user.id, limit: _nbChats),
      stream: cachedChatList.stream,
      builder: (BuildContext context, AsyncSnapshot<List<models.Chat>> snapshot) {
        // if (!snapshot.hasData && chatsCache.isEmpty) {
        //   return LoadingCircle();
        // }
        if (snapshot.hasData) {
          chatsCache.setAll(
              snapshot.data,
              snapshot.data.map((models.Chat chat) {
                return ChatTile(
                  chat: chat,
                  key: Key(chat.id),
                );
              }).toList());
        }
        if (chatsCache.isEmpty) {
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
                      children: <TextSpan>[
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
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: chatsCache.length,
              itemBuilder: (BuildContext context, int index) {
                return chatsCache.widgets[index];
              },
              separatorBuilder: (BuildContext context, int index) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0),
                child: Divider(color: Colors.grey),
              ),
            ),
          );
        }
      },
    );
  }
}
