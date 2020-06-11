import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/chat/chat_home.dart';
import 'package:nitwixt/screens/chat/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart' as database;

class ChatTile extends StatefulWidget {
  final models.Chat chat;

  ChatTile({this.chat, Key key}) : super(key: key);

  @override
  ChatTileState createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  database.DatabaseMessage _databaseMessage;

  @override
  void initState() {
    super.initState();
    _databaseMessage = database.DatabaseMessage(chatId: widget.chat.id);
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    models.User user = Provider.of<models.User>(context);

    return GestureDetector(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.chat_bubble,
              color: Colors.blue[800],
              size: 50.0,
            ),
            SizedBox(
              width: 20.0,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FutureBuilder<String>(
                    future: widget.chat.nameToDisplay(user),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          '...',
                          style: TextStyle(color: Colors.grey, fontSize: 18.0),
                          textAlign: TextAlign.left,
                        );
                      } else {
                        if (snapshot.hasError) {
                          return Text(
                            'Could not display name',
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                            textAlign: TextAlign.left,
                          );
                        } else {
                          return Text(
                            snapshot.data,
                            style: TextStyle(color: Colors.white, fontSize: 18.0),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                      }
                    },
                  ),
                  StreamBuilder<List<models.Message>>(
                    stream: _databaseMessage.getMessageList(limit: 1),
                    builder: (contextStreamBuilder, snapshot) {
                      String text;
                      if (!snapshot.hasData) {
                        text = '...';
                      } else {
                        List<models.Message> messageList = snapshot.data;
                        if (messageList.isEmpty) {
                          text = 'No message yet';
                        } else {
                          text = messageList[0].text.replaceAll('\n', ' ');
                        }
                      }
                      return Text(
                        text,
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 2,
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
        margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(color: Colors.blueGrey[800]),
        )),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatProvider(
                    id: widget.chat.id,
                    child: ChatHome(),
                  )),
        );
      },
    );
  }
}
