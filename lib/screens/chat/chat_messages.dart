import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/screens/message/message_tile.dart';
import 'package:nitwixt/shared/constants.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ChatMessages extends StatefulWidget {
  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  TextEditingController textController = TextEditingController();
  int _nbMessages = 8;

  ScrollController _scrollController;

  RefreshController _refreshController = RefreshController(initialRefresh: false);
  bool showSendButton = false;

  bool _showOptionMessageMenu = false;

  @override
  void dispose() {
    textController.dispose();
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onLoading() async {
    setState(() {
      _nbMessages += 8;
    });
    _refreshController.loadComplete();
    _refreshController.refreshCompleted();
  }

  void _textListener() {
    setState(() {
      showSendButton = textController.text.trim().isNotEmpty;
    });
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    textController.addListener(_textListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final models.Chat chat = Provider.of<models.Chat>(context);
    final database.DatabaseMessage _databaseMessage = database.DatabaseMessage(chatId: chat.id);

    void _sendMessage() async {
      if (textController.text.trim().isNotEmpty) {
//        await _databaseMessage.sendMessage(text: textController.text.trim(), userid: user.id);
        _databaseMessage.sendMessage(text: textController.text.trim(), userid: user.id);
        WidgetsBinding.instance.addPostFrameCallback((_) => textController.clear());
      }
    }

    return StreamBuilder<List<models.Message>>(
      stream: _databaseMessage.getMessageList(limit: _nbMessages),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingCircle();
        } else {
          List<models.Message> messageList = snapshot.data;
          double height = MediaQuery.of(context).size.height;
          print('show options $_showOptionMessageMenu');

          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Stack(
//                overflow: Overflow.visible,
//              alignment: Alignment.topCenter,
                  children: <Widget>[
//                  Text('coucou', style: TextStyle(color: Colors.white),),
                  // If doesn't work: try Align or Positioned
                    SizedBox(
                      child: SmartRefresher(
                        enablePullUp: true,
                        reverse: true,
                        enablePullDown: false,
                        scrollController: _scrollController,
                        controller: _refreshController,
                        primary: false,
                        onLoading: _onLoading,
                        child: ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: messageList.length,
                          reverse: true,
                          itemBuilder: (context, index) {
                            models.Message message = messageList[index];
                            return MessageTile(
                                message: message,
                                onLongPress: (models.Message message) {
                                  setState(() {
                                    _showOptionMessageMenu = true;
                                  });
                                });
                          },
                          shrinkWrap: true,
                        ),
                      ),
                    ),
                    _showOptionMessageMenu
                        ? Center(
                            child: Stack(
                              alignment: Alignment.center,
//                          fit: StackFit.loose,
//                        fit: StackFit.passthrough,
                              overflow: Overflow.visible,
                              children: <Widget>[
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  child: Container(
                                    height: double.maxFinite,
                                    width: double.maxFinite,
//                                    color: Color(0x00000000),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _showOptionMessageMenu = false;
                                    });
                                  },

                                ),
                                Container(
                                  height: 100.0,
                                  width: 100.0,
                                  color: Colors.blue,
                                  child: Text('cocou'),
                                )
                              ],
                            ),
                          )
                        : SizedBox(
                            height: 0.0,
                            width: 0.0,
                          )
                  ],
                ),
              ),
              Container(
                color: Colors.black,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        minLines: 1,
                        maxLines: 7,
                        style: TextStyle(color: Colors.white),
                        controller: textController,
                        decoration: textInputDecorationMessage.copyWith(
                          hintText: 'Type your message',
                        ),
                      ),
                    ),
                    SizedBox(width: 5.0),
                    showSendButton
                        ? IconButton(
                            icon: Icon(
                              Icons.send,
                              color: Colors.blue,
                            ),
                            onPressed: _sendMessage,
                          )
                        : SizedBox(width: 0.0),
                    SizedBox(width: textController.text.isEmpty ? 0.0 : 5.0),
                  ],
                ),
              ),
            ],
          );
        }
      },
    );
  }
}
