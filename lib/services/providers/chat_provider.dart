import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/providers/members_provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/widgets.dart';
import '../database/database_chat.dart';

class ChatProvider extends StatelessWidget {
  const ChatProvider({
    this.id,
    this.context,
    @required this.child,
  })  : assert((id == null) != (context == null), 'id and context cannot be null at the same time'),
        super();

  final String id; // Id of the chat
  final BuildContext context;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Stream<models.Chat> chatStream;
    models.Chat chat;
    if (id != null) {
      chatStream = DatabaseChat(id: id).stream;
    } else {
      chatStream = Provider.of<Stream<models.Chat>>(this.context);
      chat = Provider.of<models.Chat>(this.context);
    }
    // print('in builder');
    // chatStream.last.then(( value) {
    //   print('length $value');
    // });
    return InheritedProvider<Stream<models.Chat>>.value(
      value: chatStream,
      child: StreamProvider<models.Chat>.value(
        value: chatStream,
        initialData: chat,
        child: ChatReceiver(
          child: child,
        ),
      ),
    );
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
