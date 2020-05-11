import 'package:flutter/material.dart';
import 'package:nitwixt/screens/account/account_edit.dart';
import 'package:nitwixt/screens/account/account_info.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {

  bool isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        title: Text('Account'),
        backgroundColor: Colors.blueGrey,
        leading: new IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
          ),
        ),
      body: isEditing ? AccountEdit() : AccountInfo(),
      );
  }
}
