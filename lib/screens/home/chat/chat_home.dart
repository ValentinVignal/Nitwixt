import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:custom_navigator/custom_navigation.dart';

import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/models/models.dart' as models;

import 'chat_info.dart';
import 'chat_messages.dart';

class ChatHome extends StatefulWidget {
  @override
  _ChatHomeState createState() => _ChatHomeState();
}

class _ChatHomeState extends State<ChatHome> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    final models.Chat chat = Provider.of<models.Chat>(context);
    final models.User user = Provider.of<models.User>(context);

    return WillPopScope(
      onWillPop: () async {
        final bool canPop = _navigatorKey.currentState.canPop();
        if (canPop) {
          _navigatorKey.currentState.pop();
        }
        return !canPop;
      },
      child: CustomNavigator(
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
                const SizedBox(width: 5.0),
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
                        return const Text(
                          'Could not display name',
                          style: TextStyle(color: Colors.red, fontSize: 18.0),
                        );
                      } else {
                        return Text(snapshot.data, style: const TextStyle(color: Colors.white, fontSize: 18.0));
                      }
                    }
                  },
                ),
              ],
            ),
            backgroundColor: Colors.black,
            leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                }),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  _navigatorKey.currentState.push<ChatInfo>(
                    MaterialPageRoute<ChatInfo>(
                      builder: (BuildContext context) => ChatInfo(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: ChatMessages(),
        ),
      ),
    );
  }
}
