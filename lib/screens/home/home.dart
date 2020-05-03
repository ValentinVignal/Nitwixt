import 'package:flutter/material.dart';
import 'package:textwit/screens/account/account.dart';
import 'package:textwit/screens/chat/chat_list.dart';
import 'package:textwit/screens/settings/settings.dart';
import 'package:textwit/services/auth.dart';
import 'package:textwit/services/database.dart';
import 'package:provider/provider.dart';
import 'package:textwit/screens/home/brew_list.dart';
import 'package:textwit/models/brew.dart';
import 'settings_from.dart';
import 'package:textwit/models/user.dart';


// Different options in the popup menu
enum PopupMenuOptions { account, settings, logout }

// Get the popup menu item from the option in the enum class
PopupMenuItem<PopupMenuOptions> menuItemFromOption(PopupMenuOptions option) {
  IconData icon;
  String text;
  switch (option) {
    case PopupMenuOptions.account: {
      icon = Icons.account_circle;
      text = 'Account';
      break;
    }
    case PopupMenuOptions.settings: {
      icon = Icons.settings;
      text = 'Settings';
      break;
    }
    case PopupMenuOptions.logout: {
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
    final user = Provider.of<UserAuth>(context);

    return StreamProvider<List<UserChat>>.value(
      value: DatabaseUser(uid: user.id).userChatList,
      child: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          title: Text('Textwit'),
          backgroundColor: Colors.blueGrey,
          elevation: 0.0,
          actions: <Widget>[
            PopupMenuButton<PopupMenuOptions>(
              color: Colors.black,
              onSelected: (selected) async {
                switch(selected) {
                  case PopupMenuOptions.account: {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Account()));
                    break;
                  }
                  case PopupMenuOptions.settings: {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Settings())
                    );
                    break;
                  }
                  case PopupMenuOptions.logout: {
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
        body: ChatList(),
      ),
    );
  }
}

