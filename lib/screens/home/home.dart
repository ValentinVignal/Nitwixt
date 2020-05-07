import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:textwit/screens/account/account.dart';
import 'package:textwit/screens/chat/chat_list.dart';
import 'package:textwit/screens/settings/settings.dart';
import 'package:textwit/services/auth.dart';
import 'package:textwit/services/database.dart';
import 'package:provider/provider.dart';
import 'package:textwit/screens/home/brew_list.dart';
import 'package:textwit/models/brew.dart';
import 'package:textwit/shared/constants.dart';
import '../settings/settings_from.dart';
import 'package:textwit/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final UserAuth userAuth = Provider.of<UserAuth>(context);
    final User user = Provider.of<User>(context);
    final DatabaseUser databaseUser = DatabaseUser(uid: user.id);


    void _createNewChat(username) async {
      print('username $username');
      QuerySnapshot documents = await Firestore.instance.collection('users').where('username', isEqualTo: username).getDocuments();
      if (documents.documents.isNotEmpty) {
        User otherUser = databaseUser.userFromSnapshot(documents.documents[0]);
//        print('');
        String chatid = await Firestore.instance.collection('chats').add(
          {
            'members': [user.id, otherUser.id],
            'name': '',
          },
        ).then((DocumentReference docRef) {
          return docRef.documentID;
        });
        print('chatid $chatid');
        Map otherUserChats = otherUser.chats.map((key, userChat) {
          Map m = new Map();
          m['id'] = key;
          m['name'] = userChat.name;
          return new MapEntry(key, m);
        });
        otherUserChats[chatid] = {
          'name': '',
          'id': chatid,
        };
        Map myUserChats = user.chats.map((key, userChat) {
          Map m = new Map();
          m['id'] = key;
          m['name'] = userChat.name;
          return new MapEntry(key, m);
        });
        myUserChats[chatid] = {
          'name': '',
          'id': chatid,
        };
        print('otherChats $otherUserChats');
        Firestore.instance.collection('users').document(otherUser.id).updateData(
          {
             'chats': otherUserChats,
          },
        );
        Firestore.instance.collection('users').document(user.id).updateData(
          {
            'chats': myUserChats,
          },
          );
      }
    }

    void _showCreateNewChatPanel() {
    showDialog(
    context: context,
        builder: (BuildContext context) {

          String _enterredUsername = '@';

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
                      } else if (val[0] != '@') {
                        return 'Username must start with a "@"';
                      } else if (val.length == 1) {
                        return 'Enter username';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() {
                        setState(() {
                          _enterredUsername = val;
                        });
                      });
                    },
                  ),
                  RaisedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState.validate()) {
                        _createNewChat(_enterredUsername.substring(1));
                      }
                    },
                    icon: Icon(Icons.done),
                    label: Text('Create'),
                  )
                ],
              ),
            ),
          );
        },
      );
    }

    return StreamProvider<List<UserChat>>.value(
      value: databaseUser.userChatList,
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
                  switch (selected) {
                    case PopupMenuOptions.account:
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Account()));
                        break;
                      }
                    case PopupMenuOptions.settings:
                      {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
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
          body: ChatList(),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              _showCreateNewChatPanel();
            },
            child: Icon(Icons.add),
          )),
    );
  }
}
