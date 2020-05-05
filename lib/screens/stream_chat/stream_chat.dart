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
        sort: [scf.SortOption('last_message_at')],
        pagination: scf.PaginationParams(
          limit: 20,
        ),
        channelWidget: ChannelPage(),
      ),
    );
  }
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
