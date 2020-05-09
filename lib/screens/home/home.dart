import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:textwit/screens/account/account.dart';
import 'package:textwit/screens/home/chat_list.dart';
import 'package:textwit/services/auth.dart';
import 'package:provider/provider.dart';
import 'package:textwit/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:textwit/models/models.dart' as models;
import 'package:textwit/services/database/database.dart' as database;
import 'package:textwit/shared/loading.dart';

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
        backgroundColor: Colors.white70,
        appBar: AppBar(
          title: Text('Textwit'),
          backgroundColor: Colors.blueGrey,
          elevation: 0.0,
          actions: <Widget>[
            PopupMenuButton<PopupMenuOptions>(
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

class NewChatDialog extends StatefulWidget {
  @override
  _NewChatDialogState createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _enterredUsername = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final database.DatabaseUser databaseUser = database.DatabaseUser(id: user.id);

    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              decoration: textInputDecoration.copyWith(
                hintText: 'Username',
                labelText: 'Username',
              ),
              initialValue: _enterredUsername,
              validator: (val) {
                if (val.isEmpty) {
                  return 'Enter username';
                } else if (val == user.username) {
                  return 'Enter another username than yours';
                }
                return null;
              },
              onChanged: (val) {
                setState(() {
                  _enterredUsername = val;
                });
              },
            ),
            Text(
              error,
              style: TextStyle(color: Colors.red),
            ),
            RaisedButton.icon(
              onPressed: () async {
                if (_formKey.currentState.validate()) {
                  String res = await database.DatabaseChat.createNewChat(user, [_enterredUsername]);
                  print('res $res');
                  if (res != null) {
                    // Show the error
                    setState(() {
                      error = res;
                    });
                  } else {
                    setState(() {
                      error = '';
                    });
                    Navigator.of(context).pop();
                  }
                }
              },
              icon: Icon(Icons.done),
              label: Text('Create'),
            ),
          ],
        ),
      ),
    );
  }
}
