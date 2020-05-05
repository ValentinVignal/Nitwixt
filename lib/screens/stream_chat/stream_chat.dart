import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as scf;

class MyAppScf extends StatelessWidget {
  final scf.Client client;

  MyAppScf(this.client);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Container(
            child: scf.StreamChat(
      client: client,
      child: ChannelListPage(),
    )));
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
  final lastMessage = channel.state.messages.reversed
      .firstWhere((message) => message.type != "deleted", orElse: () => null);

  final subtitle = (lastMessage == null ? "nothing yet" : lastMessage.text);
  final opacity = channel.state.unreadCount > .0 ? 1.0 : 0.5;

  return ListTile(
    leading: scf.ChannelImage(
      channel: channel,
      ),
    title: scf.ChannelName(
      channel: channel,
      textStyle:
      scf.StreamChatTheme.of(context).channelPreviewTheme.title.copyWith(
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
            child: scf.MessageListView(),
          ),
          scf.MessageInput(),
        ],
      ),
    );
  }
}
