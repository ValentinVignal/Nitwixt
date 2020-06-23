import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:emoji_picker/emoji_picker.dart';
import 'message_option_dialog.dart';

class MessageTile extends StatefulWidget {
  models.Message message;
  DateFormat format = DateFormat('HH:mm - d MMM');
  DateTime date;
  void Function(models.Message message) onLongPress;
  void Function(models.Message message) reactButtonOnTap;

  MessageTile({
    this.message,
    this.onLongPress,
    this.reactButtonOnTap,
  }) {
    date = message.date.toDate();
  }

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  bool _showInfo = false;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<models.User>(context);
    final membersMap = Provider.of<Map<String, models.User>>(context);

    bool isMyMessage = user.id == widget.message.userid;

    Widget nameContainer = isMyMessage || membersMap.keys.length <= 2
        ? Container(
            height: 0.0,
          )
        : Container(
            padding: EdgeInsets.only(left: 5.0),
            alignment: Alignment.bottomLeft,
            height: 15.0,
            child: Text(
              membersMap[widget.message.userid].name,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12.0,
              ),
            ),
          );

    Widget dateContainer = Container(
      padding: EdgeInsets.only(
        left: 5.0,
        right: 5.0,
        top: 0.0,
        bottom: 1.0,
      ),
      alignment: isMyMessage ? Alignment.bottomRight : Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Text(
          widget.format.format(widget.date).toString(),
          style: TextStyle(color: Colors.grey[600], fontSize: 11.0),
        ),
      ),
    );

    Widget addReactButton = Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(left: isMyMessage ? 15.0 : 0.0, right: isMyMessage ? 0.0 : 15.0),
      child: IconButton(
        icon: Icon(
          Icons.insert_emoticon,
          color: Colors.grey[700],
        ),
        onPressed: () {
          if (widget.reactButtonOnTap != null) {
            widget.reactButtonOnTap(widget.message);
          }
//          print('button pressed');
        },
        padding: EdgeInsets.all(2.0),
        constraints: BoxConstraints(
          maxHeight: 24.0,
        ),
//        alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      ),
    );

    Widget reacts = widget.message.reacts.isEmpty
        ? SizedBox(
            height: 0.0,
            width: 0.0,
          )
        : Container(
            child: Text(
              '${widget.message.reacts.reactList().join()} ${widget.message.reacts.length}',
              style: TextStyle(color: Colors.white),
            ),
          );

    Widget textWidget = Flexible(
      child: GestureDetector(
        onLongPress: () {
          if (widget.onLongPress != null) {
            widget.onLongPress(widget.message);
          }
        },
        onTap: () {
          setState(() {
            _showInfo = !_showInfo;
          });
        },
        child: Container(
          margin: EdgeInsets.all(2.0),
          padding: EdgeInsets.only(top: 7.0, bottom: 7.0, right: 8.0, left: 8.0),
          decoration: BoxDecoration(
            color: isMyMessage ? Colors.blue[400] : Colors.black,
            borderRadius: BorderRadius.all(
              Radius.circular(
                20.0,
              ),
            ),
          ),
          child: Text(
            widget.message.text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.0,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ),
    );

    // * --------------------------------------------------
    // * --------------------------------------------------
    // * --------------------------------------------------

    return GestureDetector(
      child: Column(
        crossAxisAlignment: isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          nameContainer,
          SizedBox(
            width: isMyMessage ? 45.0 : 0.0,
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: <Widget>[
                  isMyMessage
                      ? addReactButton
                      : SizedBox(
                          width: 0.0,
                        ),
                  textWidget,
                  isMyMessage
                      ? SizedBox(
                          width: 0.0,
                        )
                      : addReactButton,
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    width: isMyMessage ? 40.0 : 0.0,
                  ),
                  reacts,
                  SizedBox(
                    width: isMyMessage ? 0.0 : 40.0,
                  ),
                ],
              )
            ],
          ),
          _showInfo
              ? dateContainer
              : Container(
                  height: 0.0,
                  width: 0.0,
                )
        ],
      ),
    );
  }
}

class MessageOptions extends StatefulWidget {
  models.Message message;
  void Function(models.Message, String react) onReactSelected;

  MessageOptions({
    this.message,
    this.onReactSelected,
  }) : super();

  @override
  _MessageOptionsState createState() => _MessageOptionsState();
}

class _MessageOptionsState extends State<MessageOptions> {
  bool showEmojiPicker = false;

  @override
  Widget build(BuildContext context) {
    Widget emojiButton(value) {
      return GestureDetector(
        child: Container(
          padding: EdgeInsets.all(5.0),
          child: Text(value),
        ),
        onTap: () {
          widget.onReactSelected(widget.message, value);
        },
      );
    }

    return Container(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.0), color: Colors.black),
          padding: showEmojiPicker ? null : EdgeInsets.symmetric(horizontal: 5.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  emojiButton(
                    '❤',
                  ),
                  emojiButton(
                    '😆',
                  ),
                  emojiButton(
                    '😮',
                  ),
                  emojiButton(
                    '😢',
                  ),
                  emojiButton(
                    '😠',
                  ),
                  emojiButton(
                    '👍',
                  ),
                  emojiButton(
                    '👎',
                  ),
                  IconButton(
                    icon: Icon(showEmojiPicker ? Icons.remove_circle : Icons.add_circle_outline, color: Colors.grey[700]),
                    onPressed: () {
                      setState(() {
                        showEmojiPicker = !showEmojiPicker;
                      });
                    },
                  ),
                ],
              ),
              showEmojiPicker
                  ? Container(
                      color: Colors.black,
                      child: EmojiPicker(
                        bgColor: Color(0x00000000),
                        rows: 4,
                        columns: 12,
                        onEmojiSelected: (emoji, category) {
                          widget.onReactSelected(widget.message, emoji.emoji);
                        },
                        buttonMode: ButtonMode.CUPERTINO,
                      ),
                    )
                  : SizedBox(
                      height: 0.0,
                      width: 0.0,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
