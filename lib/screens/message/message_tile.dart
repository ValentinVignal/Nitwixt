import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/models.dart' as models;

class MessageTile extends StatefulWidget {
  models.Message message;
  DateFormat format = DateFormat('HH:mm');
  DateTime date;

  MessageTile({this.message}) {
    date = DateTime.fromMillisecondsSinceEpoch(message.date.millisecondsSinceEpoch * 1000);
  }

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<models.User>(context);

    bool isMyMessage = user.id == widget.message.userid;

    Widget dateContainer = Container(
      width: 45.0,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: Text(widget.format.format(widget.date).toString(), style: TextStyle(color: Colors.grey[600]),),
      ),
      padding: EdgeInsets.only(
        left: isMyMessage ? 6.0 : 0.4,
        right: isMyMessage ? 0.4 : 6.0,
        top: 10.0,
        bottom: 0.0,
      ),
      alignment: isMyMessage ? Alignment.bottomRight : Alignment.bottomLeft,
      );

    return Row(
      mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        isMyMessage
            ? dateContainer
            : Container(
                height: 0.0,
                width: 0.0,
              ),
        Flexible(
          child: Container(
            margin: EdgeInsets.all(2.0),
            padding: EdgeInsets.only(top: 7.0, bottom: 10.0, right: 8.0, left: 8.0),
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
                fontSize: 20.0,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ),
        !isMyMessage
            ? dateContainer
            : Container(
                height: 0.0,
                width: 0.0,
              ),
      ],
    );
  }
}
