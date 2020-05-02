import 'package:flutter/material.dart';
import 'package:textwit/services/auth.dart';
import 'package:textwit/services/database.dart';
import 'package:provider/provider.dart';
import 'package:textwit/screens/home/brew_list.dart';
import 'package:textwit/models/brew.dart';
import 'settings_from.dart';

enum Options { settings, logout }

PopupMenuItem<Options> menuItemFromOption(Options option) {
  IconData icon;
  String text;
  switch (option) {
    case Options.settings: {
      icon = Icons.settings;
      text = 'Settings';
      break;
    }
    case (Options.logout): {
      icon = Icons.people;
      text = 'Logout';
      break;
    }
  }
  return PopupMenuItem<Options>(
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
    void _showSettingsPanel() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 60.0),
              child: SettingsForm(),
            );
          });
    }

    return StreamProvider<List<Brew>>.value(
      value: DatabaseService().brews,
      child: Scaffold(
        backgroundColor: Colors.white70,
        appBar: AppBar(
          title: Text('Textwit'),
          backgroundColor: Colors.blueGrey,
          elevation: 0.0,
          actions: <Widget>[
            PopupMenuButton<Options>(
              color: Colors.black,
              onSelected: (selected) async {
                switch(selected) {
                  case Options.settings: {
                    _showSettingsPanel();
                    break;
                  }
                  case Options.logout: {
                    await _auth.signOut();
                    break;
                  }
                }
              },
              itemBuilder: (BuildContext context) {
                return Options.values.map((option) {
                  return menuItemFromOption(option);
                }).toList();
              },
            ),
          ],
        ),
        body: BrewList(),
      ),
    );
  }
}

//class Choice {
//  const Choice({ this.title, this.icon, this.action });
//
//  final String title;
//  final IconData icon;
//  final Function action;
//}
//
//const List<Choice> choices = const <Choice>[
//  const Choice(title: 'Logout', icon: Icons.person, action: null),
//  const Choice(title: 'Settings', icon: Icons.settings, action: null),
//];
//
