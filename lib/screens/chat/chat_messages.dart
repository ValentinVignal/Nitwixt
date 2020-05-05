import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/message.dart';
import 'package:textwit/models/user.dart';
import 'package:textwit/screens/message/message_tile.dart';
import 'package:textwit/services/database.dart';
import 'package:textwit/shared/constants.dart';
import 'package:textwit/shared/loading.dart';

class ChatMessages extends StatefulWidget {

  final String chatid;


  ChatMessages({ this.chatid });

  @override
  _ChatMessagesState createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  TextEditingController textController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    final DatabaseChat _databaseChat = DatabaseChat(id: widget.chatid);
    final User _user = Provider.of<User>(context);

    return StreamBuilder<List<Message>>(
      stream: _databaseChat.messageList,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        } else {

          List<Message> messageList = snapshot.data;
          double height = MediaQuery.of(context).size.height;

          return SizedBox(
            height: height,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView.builder(
                    itemCount: messageList.length,
                    reverse: true,
                    itemBuilder: (context, index) {
                      return MessageTile(message: messageList[index],);
                    },
                    shrinkWrap: true,
                  ),
                ),
                TextFormField(
                  controller: textController,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'Type your message',
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.send
                      ),
                      onPressed: () {
                        if (textController.text.isNotEmpty) {
                          _databaseChat.sendMessage(
                            textController.text,
                            UserChat(
                              id: _user.id,
                              name: _user.name,
                            ),
                          );
                          textController.text = '';
                        }
                      },
                    ),
                  ),
//                  onChanged: (val) {
//                    textController.text = val;
//                  },
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
