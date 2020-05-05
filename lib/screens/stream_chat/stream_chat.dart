import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as scf;

class MyAppScf extends StatelessWidget {
  final scf.Client client;

  MyAppScf(this.client);

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      primarySwatch: Colors.green,
    );

    return MaterialApp(
      theme: theme,
      home: Container(
        child: scf.StreamChat(
          streamChatThemeData: scf.StreamChatThemeData.fromTheme(theme).copyWith(
            ownMessageTheme: scf.MessageTheme(
              messageBackgroundColor: Colors.black,
              messageText: TextStyle(
                color: Colors.white,
              ),
              avatarTheme: scf.AvatarTheme(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          client: client,
          child: ChannelListPage(),
        ),
      ),
    );
  }
}

class ChannelListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: scf.ChannelListView(
        filter: {
          'members': {
            '\$in': [scf.StreamChat.of(context).user.id],
          }
        },
        channelPreviewBuilder: _channelPreviewBuilder,
        sort: [scf.SortOption('last_message_at')],
        pagination: scf.PaginationParams(
          limit: 20,
        ),
        channelWidget: ChannelPage(),
      ),
    );
  }
}

Widget _channelPreviewBuilder(BuildContext context, scf.Channel channel) {
  final lastMessage = channel.state.messages.reversed.firstWhere((message) => message.type != "deleted", orElse: () => null);

  final subtitle = (lastMessage == null ? "nothing yet" : lastMessage.text);
  final opacity = channel.state.unreadCount > .0 ? 1.0 : 0.5;

  return ListTile(
    leading: scf.ChannelImage(
      channel: channel,
    ),
    title: scf.ChannelName(
      channel: channel,
      textStyle: scf.StreamChatTheme.of(context).channelPreviewTheme.title.copyWith(
            color: Colors.blue.withOpacity(opacity),
          ),
    ),
    subtitle: Text(subtitle),
    trailing: channel.state.unreadCount > 0
        ? CircleAvatar(
            radius: 10,
            child: Text(channel.state.unreadCount.toString()),
          )
        : SizedBox(),
  );
}

class ChannelPage extends StatelessWidget {
  const ChannelPage({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: scf.ChannelHeader(),
      body: Column(
        children: <Widget>[
          Expanded(
            child: scf.MessageListView(
              threadBuilder: (_, parentMessage) {
                return ThreadPage(
                  parent: parentMessage,
                );
              },
              //              messageBuilder: _messageBuilder,
            ),
          ),
          scf.MessageInput(),
        ],
      ),
    );
  }
}

class ThreadPage extends StatelessWidget {
  final scf.Message parent;

  ThreadPage({
    Key key,
    this.parent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: scf.ThreadHeader(
        parent: parent,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: scf.MessageListView(
              parentMessage: parent,
            ),
          ),
          scf.MessageInput(
            parentMessage: parent,
          ),
        ],
      ),
    );
  }
}

Widget _messageBuilder(context, message, index) {
  final isCurrentUser = scf.StreamChat.of(context).user.id == message.user.id;
  final textAlign = isCurrentUser ? TextAlign.right : TextAlign.left;
  final color = isCurrentUser ? Colors.blueGrey : Colors.blue;

  return Padding(
    padding: EdgeInsets.all(5.0),
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1),
        borderRadius: BorderRadius.all(
          Radius.circular(5.0),
        ),
      ),
      child: ListTile(
        title: Text(
          message.text,
          textAlign: textAlign,
        ),
        subtitle: Text(
          message.user.extraData['name'],
          textAlign: textAlign,
        ),
      ),
    ),
  );
}
