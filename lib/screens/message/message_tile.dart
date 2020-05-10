import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/models.dart' as models;

class MessageTile extends StatefulWidget {
  models.Message message;

  MessageTile({this.message});

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<models.User>(context);

    bool isMyMessage = user.id == widget.message.userid;

    return Row(
      mainAxisAlignment: isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Flexible(
          child: Padding(
            padding: isMyMessage ? EdgeInsets.only(left: 40.0) : EdgeInsets.only(right: 40.0),
            child: Container(
              margin: EdgeInsets.all(2.0),
              padding: EdgeInsets.only(top: 7.0, bottom: 10.0, right: 8.0, left: 8.0),
              decoration: BoxDecoration(
                color: isMyMessage ? Colors.blue[400] : Colors.black,
                borderRadius: BorderRadius.all(Radius.circular(20.0,),),
              ),
              child: Text(
                widget.message.text,
                style: TextStyle(color: Colors.white, fontSize: 20.0,),
                textAlign: TextAlign.justify,
              ),
            ),
          ),
        )
      ],
    );
  }
}
