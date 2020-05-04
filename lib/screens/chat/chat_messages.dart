import 'package:flutter/material.dart';
import 'package:textwit/models/message.dart';
import 'package:textwit/screens/message/message_tile.dart';
import 'package:textwit/services/database.dart';
import 'package:textwit/shared/loading.dart';

class ChatMessages extends StatelessWidget {

  final String chatid;

  ChatMessages({ this.chatid });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: DatabaseChat(id: chatid).messageList,
      builder: (context, snapshot) {
        print('snapshot');
        print(snapshot.data);
        if (!snapshot.hasData) {
          return Loading();
        } else {

          List<Message> messageList = snapshot.data;

          return ListView.builder(
            itemCount: messageList.length,
            itemBuilder: (context, index) {
              return MessageTile(message: messageList[index],);
            },
          );
        }
      },
    );
  }
}
