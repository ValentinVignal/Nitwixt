import 'package:nitwixt/screens/home/settings/settings.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nitwixt/screens/home/chat_list.dart';
import 'package:nitwixt/services/auth/auth.dart' as auth;
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/widgets.dart';

import 'account/account.dart';
import 'new_chat_dialog.dart';

// Different options in the popup menu
enum PopupMenuOptions { account, settings, logout }

// Get the popup menu item from the option in the enum class
PopupMenuItem<PopupMenuOptions> menuItemFromOption(PopupMenuOptions option) {
  IconData icon;
  String text;
  switch (option) {
    case PopupMenuOptions.account:
      {
        icon = Icons.account_circle;
        text = 'Account';
        break;
      }
    case PopupMenuOptions.settings:
      {
        icon = Icons.settings;
        text = 'Settings';
        break;
      }
    case PopupMenuOptions.logout:
      {
        icon = Icons.power_settings_new;
        text = 'Logout';
        break;
      }
  }
  return PopupMenuItem<PopupMenuOptions>(
    value: option,
    child: FlatButton.icon(
      icon: Icon(icon, color: Colors.grey),
      label: Text(text, style: const TextStyle(color: Colors.grey)),
      onPressed: null,
    ),
  );
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final auth.AuthService _auth = auth.AuthService();
  ScaffoldState scaffoldState;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void showDisclaimerSnackBar() {
    scaffoldState.showSnackBar(
      SnackBar(
//        backgroundColor: Colors.black,
        duration: const Duration(minutes: 5),
        content: const Text(
            '/!\\ Warning /!\\\nNitwixt is still a young project and I didn\'t spend much time on security and privacy of data.\nPlease don\'t put any sensitive information in this app. :)\nAlso, because of incoming data structure changes, all the data might be deleted soon O:)'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            _scaffoldKey.currentState.removeCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => showDisclaimerSnackBar());
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final models.UserPushTokens pushToken = Provider.of<models.UserPushTokens>(context);

    void _showCreateNewChatPanel() {
      showDialog<Widget>(
        context: context,
        builder: (BuildContext context) {
          return NewChatDialog();
        },
      );
    }

    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('Nitwixt'),
          elevation: 0.0,
          leading: Padding(
            padding: const EdgeInsets.all(5.0),
            child: UserPicture(
              user: user,
            ),
          ),
          actions: <Widget>[
            Builder(
              builder: (BuildContext context) {
                return PopupMenuButton<PopupMenuOptions>(
                  color: Colors.black,
                  onSelected: (PopupMenuOptions selected) async {
                    switch (selected) {
                      case PopupMenuOptions.account:
                        {
                          Navigator.push<Account>(context, MaterialPageRoute<Account>(builder: (BuildContext context) => Account()));
                          break;
                        }
                      case PopupMenuOptions.settings:
                        {
                          Navigator.of(context).push<Settings>(MaterialPageRoute<Settings>(builder: (BuildContext context) => Settings()));
                          break;
                        }
                      case PopupMenuOptions.logout:
                        {
                          await _auth.signOut(pushToken: pushToken.current);
                          break;
                        }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return PopupMenuOptions.values.map((PopupMenuOptions option) {
                      return menuItemFromOption(option);
                    }).toList();
                  },
                );
              },
            ),
          ],
        ),
        body: Builder(
          builder: (BuildContext buildContext) {
            scaffoldState = Scaffold.of(buildContext);
            return user == null ? LoadingCircle() : ChatList();
          },
        ),

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCreateNewChatPanel();
          },
          child: const Icon(Icons.add),
        ));
  }
}
