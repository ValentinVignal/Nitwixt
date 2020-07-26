import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/screens/account/account.dart';
import 'package:nitwixt/screens/home/chat_list.dart';
import 'package:nitwixt/services/auth/auth.dart' as auth;
import 'package:nitwixt/widgets/profile_picture.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/widgets.dart';
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
      label: Text(text, style: TextStyle(color: Colors.grey)),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showDisclaimerSnackBar() {
    scaffoldState.showSnackBar(
      SnackBar(
//        backgroundColor: Colors.black,
        duration: const Duration(minutes: 5),
        content: Text(
            '/!\\ Warning /!\\\nNitwixt is still a young project and I didn\'t spend much time on security and privacy of data.\nPlease don\'t put any sensitive information in this app. :)\nAlso, because of incoming data structure changes, all the data might be deleted soon O:)\n\nAlso, I am very sorry but I had to delete all the pictures, you may upload new photos  if you want'),
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
    final models.PushToken pushToken = Provider.of<models.PushToken>(context);

    void _showCreateNewChatPanel() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return NewChatDialog();
        },
      );
    }

    return Scaffold(
        key: _scaffoldKey,
//        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Text('Nitwixt'),
//          backgroundColor: Colors.grey[900],
//          backgroundColor: Colors.black,
          elevation: 0.0,
          leading: Padding(
            padding: EdgeInsets.all(5.0),
            child: UserPicture(
              user: user,
            ),
          ),
          actions: <Widget>[
            Builder(
              builder: (context) {
                return PopupMenuButton<PopupMenuOptions>(
                  color: Colors.black,
                  onSelected: (selected) async {
                    switch (selected) {
                      case PopupMenuOptions.account:
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => Account()));
                          break;
                        }
                      case PopupMenuOptions.settings:
                        {
//                        Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
                          final SnackBar snackbar = SnackBar(
                            content: Text('No setting available for now'),
                          );
                          Scaffold.of(context).showSnackBar(snackbar);
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
                    return PopupMenuOptions.values.map((option) {
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

//        body: user == null ? Loading() : ChatList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCreateNewChatPanel();
          },
          child: Icon(Icons.add),
        ));
  }
}
