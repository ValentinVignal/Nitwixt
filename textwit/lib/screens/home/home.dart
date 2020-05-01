import 'package:flutter/material.dart';
import 'package:textwit/services/auth.dart';
import 'package:textwit/services/database.dart';
import 'package:provider/provider.dart';
import 'package:textwit/screens/home/brew_list.dart';
import 'package:textwit/models/brew.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final AuthService _auth = AuthService();

    return StreamProvider<List<Brew>>.value(
      value: DatabaseService().brews,
      child: Scaffold(
        backgroundColor: Colors.green[50],
        appBar: AppBar(
          title: Text('Textwit'),
          backgroundColor: Colors.green[400],
          elevation: 0.0,
          actions: <Widget>[
            FlatButton.icon(
                icon: Icon(Icons.person),
                label: Text('logout'),
                onPressed: () async {
                  await _auth.signOut();
                })
          ],
        ),
        body: BrewList(),
      ),
    );
  }
}
