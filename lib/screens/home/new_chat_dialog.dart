import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/shared/constants.dart';

class NewChatDialog extends StatefulWidget {
  @override
  _NewChatDialogState createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> _enterredUsernames = [''];
  String error = '';

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final database.DatabaseUser databaseUser = database.DatabaseUser(id: user.id);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      backgroundColor: Color(0xFF202020),
      content: Container(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Select the usernames of the members',
                style: TextStyle(color: Colors.grey, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.0),
              Container(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _enterredUsernames.length,
                  itemBuilder: (BuildContext buildContextList, int index) {
                    return Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            decoration: textInputDecoration.copyWith(
                              hintText: 'Username',
                              labelText: 'Username',
                            ),
                            initialValue: _enterredUsernames[index],
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
                                _enterredUsernames[index] = val;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            size: 30.0,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            setState(() {
                              _enterredUsernames.removeAt(index);
                            });
                          },
                        )
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 10.0),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _enterredUsernames.add('');
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(Icons.add, color: Colors.blue,),
                    SizedBox(width: 5.0),
                    Text('Add', style: TextStyle(color: Colors.blue),)
                  ],
                )
              ),
              SizedBox(height: 10.0),
              Text(
                error,
                style: TextStyle(color: Colors.red),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white,
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.close,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Cancel',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 5.0),
                  GestureDetector(
                    onTap: () async {
                      if (_formKey.currentState.validate()) {
                        String res = await database.DatabaseChat.createNewChat(user, _enterredUsernames);
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
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 10.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green,
                          width: 2.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 5.0,
                          ),
                          Text(
                            'Create',
                            style: TextStyle(color: Colors.green, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
//            RaisedButton.icon(
//              onPressed: () async {
//                if (_formKey.currentState.validate()) {
//                  String res = await database.DatabaseChat.createNewChat(user, [_enterredUsername]);
//                  print('res $res');
//                  if (res != null) {
//                    // Show the error
//                    setState(() {
//                      error = res;
//                    });
//                  } else {
//                    setState(() {
//                      error = '';
//                    });
//                    Navigator.of(context).pop();
//                  }
//                }
//              },
//              icon: Icon(Icons.done),
//              label: Text('Create'),
//            ),
            ],
          ),
        ),
      ),
    );
  }
}
