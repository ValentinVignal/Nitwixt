import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/services/providers/providers.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/models/models.dart' as models;

import 'chat/chat_home.dart';

class ChatTile extends StatefulWidget {
  const ChatTile({this.chat, Key key}) : super(key: key);

  final models.Chat chat;

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
    final models.User user = Provider.of<models.User>(context);

    return GestureDetector(
      child: Container(
        height: 55.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            ChatPicture(
              chat: widget.chat,
              user: user,
              size: 25.0,
            ),
            const SizedBox(width: 20.0),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  FutureBuilder<String>(
                    future: widget.chat.nameToDisplay(user),
                    builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return LoadingDots(
                          color: Colors.grey,
                          fontSize: 18.0,
                        );
                      } else {
                        if (snapshot.hasError) {
                          return const Text(
                            'Could not display name',
                            style: TextStyle(color: Colors.red, fontSize: 18.0),
                            textAlign: TextAlign.left,
                          );
                        } else {
                          return Text(
                            snapshot.data,
                            style: const TextStyle(fontSize: 18.0),
                            textAlign: TextAlign.left,
                            overflow: TextOverflow.ellipsis,
                          );
                        }
                      }
                    },
                  ),
                  StreamBuilder<List<models.Message>>(
                    stream: _databaseMessage.getList(limit: 1),
                    builder: (BuildContext contextStreamBuilder, AsyncSnapshot<List<models.Message>> snapshot) {
                      String text = '';
                      if (!snapshot.hasData) {
                        return LoadingDots(
                          color: Colors.grey,
                          fontSize: 14.0,
                        );
                      } else {
                        final List<models.Message> messageList = snapshot.data;
                        if (messageList.isEmpty) {
                          text = 'No message yet';
                        } else {
                          final models.Message message = messageList[0];
                          if (message.hasImages) {
                            text += '📷' * message.images.length + ' ';
                          }
                          text += message.text.replaceAll('\n', ' ');
                        }
                      }
                      return Text(
                        text,
                        style: Theme.of(context).textTheme.subtitle1,
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
        margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
        decoration: BoxDecoration(
            border: Border(
          bottom: BorderSide(color: Colors.blueGrey[800]),
        )),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute<Widget>(
              builder: (BuildContext context) => ChatProvider(
                    id: widget.chat.id,
                    child: ChatHome(),
                  )),
        );
      },
    );
  }
}
