import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;

class MessageToAnswerTo extends StatelessWidget {
  models.Message message;
  Function onCancel;

  Color color = Color(0xFFBBBBBB);
  Color backgroundColor = Color(0xFF101010);

  MessageToAnswerTo({
    @required this.message,
    this.onCancel,
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Container(
        color: backgroundColor,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                message.text.replaceAll('\n', ' '),
                style: TextStyle(color: color),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.clear,
                color: color,
              ),
              onPressed: this.onCancel,
            ),
          ],
        ));
  }
}
