import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as scf;

class MyAppScf extends StatelessWidget {
  final scf.Client client;
  final scf.Channel channel;

  MyAppScf(this.client, this.channel);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: scf.StreamChat(
        client: client,
        child: scf.StreamChannel(
          channel: channel,
          child: ChannelPage(),
          ),
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