import 'package:flutter/material.dart';
import 'file:///D:/Valentin/Code/Nitwixt/Nitwixt/lib/services/providers/members_provider.dart';
import 'package:provider/provider.dart';
import '../database/database_chat.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/widgets.dart';

class ChatProvider extends StatelessWidget {
  final String id; // Id of the chat
  final models.Chat chat;
  final Widget child;

  ChatProvider({
    this.id,
    this.chat,
    @required this.child,
  }) : super() {
    assert ((chat == null) != (id == null));
  }

  @override
  Widget build(BuildContext context) {
    if (id != null) {
      return StreamProvider<models.Chat>.value(
        value: DatabaseChat(chatId: this.id).chatStream,
        child: ChatReceiver(
          child: this.child,
        ),
      );
    } else {
      return Provider<models.Chat>.value(
        value: this.chat,
        child: ChatReceiver(
          child: this.child,
        ),
      );
    }
  }
}

class ChatReceiver extends StatelessWidget {
  final Widget child;

  ChatReceiver({@required this.child}) : super();

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
        child: this.child,
      );
    }
  }
}
