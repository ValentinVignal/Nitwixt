import 'package:flutter/material.dart';
import 'package:textwit/models/models.dart' as models;
import 'package:provider/provider.dart';
import 'package:textwit/services/database/database.dart' as database;
import 'package:textwit/shared/constants.dart';

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
