import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/services/providers/providers.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'chat_messages.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'chat_info.dart';
import 'package:custom_navigator/custom_navigation.dart';

class ChatHome extends StatefulWidget {
  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final models.Chat chat = Provider.of<models.Chat>(context);
    final models.User user = Provider.of<models.User>(context);

    return CustomNavigator(
      navigatorKey: _navigatorKey,
      pageRoute: PageRoutes.materialPageRoute,
      home: Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ChatPicture(
                chat: chat,
                user: user,
                size: 20.0,
              ),
              SizedBox(width: 5.0),
              FutureBuilder<String>(
                future: chat.nameToDisplay(user),
                builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return LoadingDots(
                      color: Colors.grey,
                      fontSize: 18.0,
                    );
                  } else {
                    if (snapshot.hasError) {
                      return Text(
                        'Could not display name',
                        style: TextStyle(color: Colors.red, fontSize: 18.0),
                      );
                    } else {
                      return Text(snapshot.data, style: TextStyle(color: Colors.white, fontSize: 18.0));
                    }
                  }
                },
              ),
            ],
          ),
          backgroundColor: Colors.black,
          leading: new IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: () {
                Navigator.pop(context);
              }),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.info_outline),
              onPressed: () {
                _navigatorKey.currentState.push(
                  MaterialPageRoute(
                    builder: (context) => ChatInfo(),
                  ),
                );
              },
            ),
          ],
        ),
        body: ChatMessages(),
      ),
    );
  }
}
