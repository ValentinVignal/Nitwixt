import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:nitwixt/screens/home/chat/message/edited_message.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/services/database/database.dart' as database;

import 'chat_messages_cache.dart';
import 'message/message_tile.dart';
import 'message/message_to_answer_to.dart';

class ChatMessages extends StatefulWidget {
  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  int _nbMessages = 16;

  ScrollController _scrollController;

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  final PopupController _popupController = PopupController();

  models.Message messageToAnswer;
  models.Message messageToEdit;

  final ChatMessagesCache _chatMessagesCache = ChatMessagesCache();

  @override
  void dispose() {
    _scrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  void _onLoading() {
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
    setState(() {
      messageToAnswer = message;
    });
  }


  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final models.Chat chat = Provider.of<models.Chat>(context);
    final database.DatabaseMessage _databaseMessage = database.DatabaseMessage(chatId: chat.id);

    Future<void> setMessageToEdit(models.Message message) async {
      models.Message previousMessage;
      if (message != null && message.previousMessageId != null) {
        try {
          previousMessage = await _databaseMessage.getMessageFuture(message.previousMessageId);
        } catch (e) {
          print('error setting previous message: $e');
        }
      }
      setState(() {
        messageToAnswer = previousMessage;
        messageToEdit = message;
      });
    }

    void _sendMessage({String text, File image}) {
      if (text.trim().isNotEmpty || image != null) {
        if (messageToEdit == null) {
          _databaseMessage.send(
            text: text.trim(),
            userid: user.id,
            previousMessageId: messageToAnswer != null ? messageToAnswer.id : null,
            image: image,
          );
        } else {
          _databaseMessage.updateMessage(
            messageId: messageToEdit.id,
            obj: <String, String>{
              models.MessageKeys.text: text.trim(),
              models.MessageKeys.previousMessageId: messageToAnswer != null ? messageToAnswer.id : null,
            }
          );
        }
        setMessageToAnswer(null);
        setMessageToEdit(null);
      }
    }

    Future<void> _reactToMessage(models.Message message, String react) async {
      if (message.reacts.containsKey(user.id) && message.reacts[user.id] == react) {
        // Unreact
        message.reacts.remove(user.id);
      } else {
        // react
        message.reacts[user.id] = react;
      }
      _popupController.hide();
      await _databaseMessage.updateMessage(
        messageId: message.id,
        obj: <String, dynamic>{
          'reacts': message.toFirebaseObject()['reacts'],
        },
      );
    }

    return StreamBuilder<List<models.Message>>(
      stream: _databaseMessage.getList(limit: _nbMessages),
      builder: (BuildContext context, AsyncSnapshot<List<models.Message>> snapshot) {
        if (snapshot.hasData) {
          _chatMessagesCache.addMessageList(
            snapshot.data,
            snapshot.data.map((models.Message message) {
              return MessageTile(
                message: message,
                reactButtonOnTap: (models.Message message) {
                  _popupController.show();
                  _popupController.object = message;
                },
                onAnswer: setMessageToAnswer,
                onEdit: setMessageToEdit,
              );
            }).toList(),
          );
        }
        if (!snapshot.hasData && _chatMessagesCache.isEmpty) {
          return LoadingCircle();
        }
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
                      itemCount: _chatMessagesCache.messageList.length,
                      reverse: true,
                      itemBuilder: (BuildContext context, int index) {
                        final models.Message message = _chatMessagesCache.messageList[index];
                        return _chatMessagesCache.widgets[message.id];
                      },
                      shrinkWrap: true,
                    ),
                  ),
                ),
                childFront: Builder(
                  builder: (BuildContext context) {
                    return ReactPopup(
                      message: _popupController.object as models.Message,
                      onReactSelected: _reactToMessage,
                    );
                  },
                ),
              ),
            ),
            if (messageToAnswer != null)
              MessageToAnswerTo(
                message: messageToAnswer,
                onCancel: () {
                  setMessageToAnswer(null);
                },
              ),
            if (messageToEdit != null)
              EditedMessage(
                message: messageToEdit,
                onCancel: () {
                  setMessageToEdit(null);
                },
              ),
            InputTextMessage(
              sendMessage: _sendMessage,
              sendIcon: messageToEdit == null ? Icons.send : Icons.check,
              initialText: messageToEdit != null ? messageToEdit.text : null,
              allowImages: messageToEdit == null,
            )
          ],
        );
      },
    );
  }
}
