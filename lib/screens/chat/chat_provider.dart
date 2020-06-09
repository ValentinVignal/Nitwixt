import 'package:flutter/material.dart';
import 'package:nitwixt/screens/chat/members_provider.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/screens/chat/chat_home.dart';
import 'package:nitwixt/services/database/database_chat.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/shared/loading.dart';

class ChatProvider extends StatelessWidget {

  final String id;
  ChatProvider({ this.id });

  @override
  Widget build(BuildContext context) {
    return StreamProvider<models.Chat>.value(
      value: DatabaseChat(chatId: this.id).chat,
      child: ChatReceiver(),
    );
  }
}

class ChatReceiver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final models.Chat chat = Provider.of<models.Chat>(context);

    if (chat == null) {
      return Scaffold(
        body: Loading(),
      );
    } else {
      return MembersProvider(chat: chat,);
    }

  }
}

