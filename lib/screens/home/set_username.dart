import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart';
import 'package:nitwixt/services/auth.dart';
import 'package:nitwixt/services/database/database.dart';
import 'package:nitwixt/shared/constants.dart';
import 'package:nitwixt/shared/loading.dart';
import 'package:nitwixt/services/database/collections.dart';

class SetUsername extends StatefulWidget {
  @override
  _SetUsernameState createState() => _SetUsernameState();
}

class _SetUsernameState extends State<SetUsername> {
  final _formKey = GlobalKey<FormState>();
  final RegExp usernameRegExp = RegExp(r'^[a-zA-Z0-9_-]$');
  bool loading = false;
  String username = '';
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<User>(context);
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white70,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: Text('Nitwixt'),
        leading: IconButton(
          onPressed: () => AuthService().signOut(),
          icon: Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: height,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50.0),
                  Text('Choose a username',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 20.0,
                      )),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    initialValue: user.username,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Username',
                      labelText: 'Username',
                    ),
                    validator: (val) {
                      if (val.isEmpty) {
                        return 'Enter a username';
                      } else if (!usernameRegExp.hasMatch(val)) {
                        return 'A username can only contain letters, numbers, _ and -';
                      }
                      return null;
                    },
                    onChanged: (val) {
                      setState(() => username = val);
                    },
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  RaisedButton.icon(
                    onPressed: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() {
                          loading = true;
                        });
                        QuerySnapshot documents = await userCollection.where('username', isEqualTo: username).getDocuments();
                        if (documents.documents.isNotEmpty) {
                          // There is already a user with this username
                          setState(() {
                            errorMessage = 'Username $username is already used';
                            loading = false;
                          });
                        } else {
                          // Username doesn't exist -> update the user record
                          user.username = username;
                          user.name = username;
                          await DatabaseUser.createUser(user: user).catchError((errorMessage) {
                            setState(() {
                              errorMessage = 'Could not set the username $username';
                              loading = false;
                            });
                          });
                        }
                      }
                    },
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text('Confirm',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                        )),
                    color: Colors.blue,
                  ),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 15.0,
                    ),
                  ),
                  loading
                      ? Loading()
                      : Container(
                          height: 0.0,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
