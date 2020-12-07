import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:nitwixt/src/date/date_formater.dart';
import 'package:provider/provider.dart';

import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/services/providers/providers.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/models/models.dart' as models;

import 'chat/chat_home.dart';

class ChatTile extends StatefulWidget {
  const ChatTile({
    this.chat,
    Key key,
  }) : super(key: key);

  final models.Chat chat;

  @override
  ChatTileState createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  database.DatabaseMessage _databaseMessage;
  final DateFormatter dateFormater = DateFormatter();

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

    final Stream<List<models.Message>> lastMessageListStream = _databaseMessage.getList(limit: 1);

    return StreamBuilder<List<models.Message>>(
      stream: lastMessageListStream,
      builder: (BuildContext context, AsyncSnapshot<List<models.Message>> messageListSnapshot) {
        final List<models.Message> messageList = messageListSnapshot.data;
        models.Message message;
        bool isRead = true;
        if (messageListSnapshot.hasData && messageListSnapshot.data.isNotEmpty) {
          message = messageList[0];
          isRead = message.isReadBy(user.id);
        }
        return ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Flexible(
                  child: FutureBuilder<String>(
                    future: widget.chat.nameToDisplay(user),
                    builder: (BuildContext context, AsyncSnapshot<String> chatNameSnapshot) {
                      if (chatNameSnapshot.connectionState == ConnectionState.waiting) {
                        return LoadingDots(
                          color: Colors.grey,
                          fontSize: 18.0,
                        );
                      } else if (chatNameSnapshot.hasError) {
                        return const Text(
                          'Could not display name',
                          style: TextStyle(color: Colors.red, fontSize: 18.0),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        );
                      } else {
                        return Text(
                          chatNameSnapshot.data,
                          style: TextStyle(
                            fontSize: 18.0,
                            color: isRead ? Colors.white : Colors.blue,
                            fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          ),
                          textAlign: TextAlign.left,
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                    },
                  ),
                ),
                Visibility(
                  visible: message != null,
                  child: Builder(
                    builder: (BuildContext context) {
                      final TextStyle style = Theme.of(context).textTheme.subtitle1.copyWith(
                            fontWeight: message.seenBy.isNotReadBy(user.id) ? FontWeight.bold : null,
                            color: isRead ? Colors.grey : Colors.grey[300],
                          );

                      final DateTime date = message.date.toDate();
                      return Text(
                        dateFormater.short(date),
                        key: Key('date-${message.id}'),
                        style: style,
                      );
                    },
                  ),
                ),
              ],
            ),
            subtitle: Builder(
              builder: (BuildContext context) {
                String text = '';
                Key key;
                TextStyle style = Theme.of(context).textTheme.subtitle1;
                if (messageList == null) {
                  return LoadingDots(
                    color: Colors.grey,
                    fontSize: 14.0,
                  );
                } else {
                  if (messageList.isEmpty) {
                    text = 'No message yet';
                  } else {
                    key = Key(message.id);
                    if (message.hasImages) {
                      text += '📷' * message.images.length + ' ';
                    }
                    text += message.text.replaceAll('\n', ' ');
                    if (!isRead) {
                      style = Theme.of(context).textTheme.subtitle1.copyWith(
                            color: Colors.grey[300],
                          );
                    }
                  }
                }
                return Text(
                  text,
                  style: style,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 2,
                  key: key,
                );
              },
            ),
            leading: ChatPicture(
              chat: widget.chat,
              user: user,
              size: 25.0,
            ),
            trailing: Visibility(
              visible: !isRead,
              child: const Icon(
                Icons.circle,
                color: Colors.blue,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<Widget>(
                  builder: (BuildContext context) => ChatProvider(
                    id: widget.chat.id,
                    child: ChatHome(),
                  ),
                ),
              );
            });
      },
    );

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: FutureBuilder<String>(
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
                                  overflow: TextOverflow.ellipsis,
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
                      ),
                      StreamBuilder<List<models.Message>>(
                          stream: lastMessageListStream,
                          builder: (BuildContext buildContext, AsyncSnapshot<List<models.Message>> snapshot) {
                            if (snapshot.hasError || !snapshot.hasData || snapshot.data.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            final models.Message message = snapshot.data.first;
                            final TextStyle style = Theme.of(context).textTheme.subtitle1.copyWith(
                                  fontWeight: message.seenBy.isNotReadBy(user.id) ? FontWeight.bold : null,
                                );

                            final DateTime date = message.date.toDate();
                            return Text(
                              dateFormater.short(date),
                              key: Key('date-${message.id}'),
                              style: style,
                            );
                          })
                    ],
                  ),
                  StreamBuilder<List<models.Message>>(
                    stream: lastMessageListStream,
                    builder: (BuildContext contextStreamBuilder, AsyncSnapshot<List<models.Message>> snapshot) {
                      String text = '';
                      Key key;
                      TextStyle style = Theme.of(context).textTheme.subtitle1;
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
                          key = Key(message.id);
                          if (message.hasImages) {
                            text += '📷' * message.images.length + ' ';
                          }
                          text += message.text.replaceAll('\n', ' ');
                          if (message.seenBy.isNotReadBy(user.id)) {
                            style = Theme.of(context).textTheme.subtitle1.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent);
                          }
                        }
                      }
                      return Text(
                        text,
                        style: style,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 2,
                        key: key,
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
            ),
          ),
        );
      },
    );
  }
}
