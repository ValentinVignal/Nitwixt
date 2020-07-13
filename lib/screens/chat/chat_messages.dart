import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/screens/message/message_tile.dart';
import 'package:nitwixt/screens/message/message_to_answer_to.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:nitwixt/shortcuts/shortcuts.dart' as sc;

class ChatMessages extends StatefulWidget {
  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  int _nbMessages = 8;

  ScrollController _scrollController;

  RefreshController _refreshController = RefreshController(initialRefresh: false);

  PopupController _popupController = PopupController();

  models.Message messageToAnswer;

  @override
  void dispose() {
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


  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  void setMessageToAnswer(models.Message message) {
    message == null ? print('message null') : print('message ${message.id}');
    setState(() {
      messageToAnswer = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final models.Chat chat = Provider.of<models.Chat>(context);
    final database.DatabaseMessage _databaseMessage = database.DatabaseMessage(chatId: chat.id);

    void _sendMessage(String text) async {
      if (text.trim().isNotEmpty) {
        _databaseMessage.sendMessage(
          text: text.trim(),
          userid: user.id,
          previousMessageId: messageToAnswer != null ? messageToAnswer.id : null,
        );
        setMessageToAnswer(null);
      }
    }



    void _reactToMessage(models.Message message, String react) async {
      if (message.reacts.containsKey(user.id) && message.reacts[user.id] == react) {
        // Unreact
        message.reacts.remove(user.id);
      } else {
        // react
        message.reacts[user.id] = react;
      }
      this._popupController.hide();
      await _databaseMessage.updateMessage(
        messageId: message.id,
        obj: {
          'reacts': message.toFirebaseObject()['reacts'],
        },
      );
    }

    return StreamBuilder<List<models.Message>>(
      stream: _databaseMessage.getMessageList(limit: _nbMessages),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LoadingCircle();
        } else {
          List<models.Message> messageList = snapshot.data;
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: Popup(
                  controller: _popupController,
                  childBack: SizedBox(
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
                            reactButtonOnTap: (models.Message message) {
                              this._popupController.show();
                              this._popupController.object = message;
                            },
                            onAnswerDrag: (models.Message message) {
                              setMessageToAnswer(message);
                            },
                          );
                        },
                        shrinkWrap: true,
                      ),
                    ),
                  ),
                  childFront: Builder(
                    builder: (context) {
                      return ReactPopup(
                        message: this._popupController.object,
                        onReactSelected: _reactToMessage,
                      );
                    },
                  ),
                ),
              ),
              messageToAnswer != null
                  ? MessageToAnswerTo(
                      message: messageToAnswer,
                      onCancel: () {
                        setMessageToAnswer(null);
                      },
                    )
                  : SizedBox.shrink(),
            InputTextMessage(
              sendMessage: _sendMessage,
            )
            ],
          );
        }
      },
    );
  }
}

