import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/message.dart';
import 'package:textwit/models/user.dart';
import 'package:textwit/screens/message/message_tile.dart';
import 'package:textwit/services/database/database_old.dart';
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
  int _nbMessages = 8;
  ScrollController _scrollController;

  _scrollListener () {
    if (_scrollController.position.maxScrollExtent == _scrollController.position.pixels) {
      setState(() {
        _nbMessages += 8;
      });
    }
  }

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final DatabaseChat _databaseChat = DatabaseChat(id: widget.chatid);
    final User _user = Provider.of<User>(context);


    return StreamBuilder<List<Message>>(
      stream: _databaseChat.getMessageList(limit: _nbMessages),
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
                    controller: _scrollController,
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
                            ChatPublic(
                              id: _user.id,
                              name: _user.name,
                            ),
                          );
                          textController.text = '';
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
