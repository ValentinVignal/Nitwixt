import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/providers/members_provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/widgets.dart';
import '../database/database_chat.dart';

class ChatProvider extends StatelessWidget {
  const ChatProvider({
    this.id,
    this.chat,
    @required this.child,
  })  : assert((chat == null) != (id == null), 'Either chat or id should be specified'),
        super();

  final String id; // Id of the chat
  final models.Chat chat;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (id != null) {
      return StreamProvider<models.Chat>.value(
        value: DatabaseChat(chatId: id).chatStream,
        child: ChatReceiver(
          child: child,
        ),
      );
    } else {
      return Provider<models.Chat>.value(
        value: chat,
        child: ChatReceiver(
          child: child,
        ),
      );
    }
  }
}

class ChatReceiver extends StatelessWidget {
  const ChatReceiver({
    @required this.child,
  }) : super();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final models.Chat chat = Provider.of<models.Chat>(context);

    if (chat == null) {
      return Scaffold(
        body: LoadingCircle(),
      );
    } else {
      return MembersProvider(
        chat: chat,
        child: child,
      );
    }
  }
}
