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
    return FutureBuilder<Stream<Map<String, models.User>>>(
      future: DatabaseUserMixin.getUserMap(chatid: chat.id) ,
      builder: (BuildContext context, AsyncSnapshot<Stream<Map<String, models.User>>> snapshot) {
        Stream<Map<String, models.User>> stream = Stream<Map<String, models.User>>.value(<String, models.User>{});
        if (!snapshot.hasError && snapshot.hasData) {
          stream = snapshot.data;
        }
        return StreamProvider<Map<String, models.User>>.value(
          value: stream,
          child: MembersMapReceiver(
            child: child,
          ),
        );
      }
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
