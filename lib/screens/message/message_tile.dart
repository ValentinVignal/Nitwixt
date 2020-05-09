import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/models.dart' as models;

class MessageTile extends StatefulWidget {

  models.Message message;

  MessageTile({ this.message });

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<models.User>(context);

    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        color: widget.message.userid == user.id ? Colors.blue : Colors.red,
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
