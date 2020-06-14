import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/widgets.dart';
import 'package:provider/provider.dart';
import '../database/database.dart';

class MembersProvider extends StatelessWidget {
  final models.Chat chat;
  final Widget child;

  MembersProvider({
    @required this.chat,
    @required this.child,
  }): super();

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<models.User>>.value(
      value: DatabaseUser.getUserList(chatid: chat.id),
      child: MembersReceiver(
        child: this.child,
      ),
    );
  }
}

class MembersReceiver extends StatelessWidget {
  final Widget child;

  MembersReceiver({
    @required this.child,
}) : super();

  @override
  Widget build(BuildContext context) {
    final List<models.User> membersList = Provider.of<List<models.User>>(context);
    Map<String, models.User> membersMap;

    if (membersList == null) {
      return Scaffold(
        body: LoadingCircle(),
      );
    } else {
      membersMap = membersList.asMap().map<String, models.User>((int index, models.User user) {
        return MapEntry(user.id, user);
      });
      return Provider<Map<String, models.User>>.value(
        value: membersMap,
        child: MembersMapReceiver(
          child: this.child
        ),
      );
    }
  }
}

class MembersMapReceiver extends StatelessWidget {
  final Widget child;

  MembersMapReceiver({
    @required this.child,
  }) : super();

  @override
  Widget build(BuildContext context) {
    final Map<String, models.User> membersMap = Provider.of<Map<String, models.User>>(context);

    if (membersMap == null) {
      return Scaffold(
        body: LoadingCircle(),
      );
    } else {
      return this.child;
    }
  }
}
