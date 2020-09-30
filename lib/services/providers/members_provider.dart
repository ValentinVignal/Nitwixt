import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../database/database.dart';

class MembersProvider extends StatelessWidget {
  const MembersProvider({
    @required this.chat,
    @required this.child,
  }): super();

  final models.Chat chat;
  final Widget child;


  @override
  Widget build(BuildContext context) {
    return StreamProvider<Map<String, models.User>>.value(
      value: DatabaseUserMixin.getUserMap(chatid: chat.id),
      child: MembersMapReceiver(
        child: child,
      ),
    );
  }
}

class MembersMapReceiver extends StatelessWidget {

  const MembersMapReceiver({
    @required this.child,
  }) : super();

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Map<String, models.User> membersMap = Provider.of<Map<String, models.User>>(context);

    if (membersMap == null) {
      return Scaffold(
        body: LoadingCircle(),
      );
    } else {
      return child;
    }
  }
}
