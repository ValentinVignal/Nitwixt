import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/screens/account/account.dart';
import 'package:nitwixt/screens/home/chat_list.dart';
import 'package:nitwixt/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/shared/loading.dart';
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
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);

    void _showCreateNewChatPanel() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return NewChatDialog();
        },
      );
    }

    return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Text('Nitwixt'),
          backgroundColor: Colors.blueGrey[800],
          elevation: 0.0,
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
                          await _auth.signOut();
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
        body: user == null ? Loading() : ChatList(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showCreateNewChatPanel();
          },
          child: Icon(Icons.add),
        ));
  }
}
