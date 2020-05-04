import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/message.dart';
import 'package:textwit/models/user.dart';
import 'package:textwit/services/auth.dart';

class MessageTile extends StatefulWidget {

  Message message;

  MessageTile({ this.message });

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserAuth>(context);

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        color: widget.message.user.id == user.id ? Colors.blue : Colors.red,
        margin: EdgeInsets.fromLTRB(20.0, 6.0, 20.0, 0.0),
        child: ListTile(
          leading: CircleAvatar(
            radius: 25.0,
            backgroundImage: AssetImage('assets/images/message.png'),
            ),
          title: Text(widget.message.text),
          subtitle: Text(widget.message.date.toString()),
          ),
        ),
      );
  }
}
