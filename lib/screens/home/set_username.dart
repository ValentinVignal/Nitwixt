import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/services/database/database_user_mixin.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/models/models.dart';
import 'package:nitwixt/services/auth/auth_service.dart';
import 'package:nitwixt/services/database/database.dart';
import 'package:nitwixt/shared/constants.dart';
import 'package:nitwixt/services/database/collections.dart';
import 'package:nitwixt/widgets/widgets.dart';

class SetUsername extends StatefulWidget {
  @override
  _SetUsernameState createState() => _SetUsernameState();
}

class _SetUsernameState extends State<SetUsername> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final RegExp usernameRegExp = RegExp(r'^[a-zA-Z0-9_-]*$');
  bool loading = false;
  String username = '';
  String errorMessage = '';
  bool olderThan13Yo = false;

  @override
  Widget build(BuildContext context) {
    final User user = Provider.of<User>(context);
    final double height = MediaQuery.of(context).size.height;

    Future<void> _validate() async {
      if (_formKey.currentState.validate()) {
        setState(() {
          loading = true;
        });
        final QuerySnapshot documents = await userCollection.where(UserKeys.username, isEqualTo: username).get();
        if (documents.docs.isNotEmpty) {
          // There is already a user with this username
          setState(() {
            errorMessage = 'Username $username is already used';
            loading = false;
          });
        } else {
          // Username doesn't exist -> update the user record
          user.username = username;
          user.name = username;
          await DatabaseUserMixin.createUser(user: user).catchError((String errorMessage) {
            setState(() {
              errorMessage = 'Could not set the username $username';
              loading = false;
            });
          });
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nitwixt'),
        leading: IconButton(
          onPressed: () => AuthService().signOut(),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: height,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 50.0),
                  Text('Choose a username',
                      style: TextStyle(
                        color: Colors.grey[300],
                        fontSize: 20.0,
                      )),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    initialValue: user.username,
                    decoration: textInputDecoration.copyWith(
                      hintText: 'Username',
                      labelText: 'Username',
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (String val) {
                      if (val.isEmpty) {
                        return 'Enter a username';
                      } else if (!usernameRegExp.hasMatch(val)) {
                        return 'A username can only contain letters, numbers, _ and -';
                      }
                      return null;
                    },
                    onChanged: (String val) {
                      setState(() => username = val);
                    },
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  CheckboxFormField(
                      title: const Text('I have more than 13 years old'),
                      initialValue: olderThan13Yo,
                      validator: (bool val) {
                        if (val) {
                          return null;
                        } else {
                          return 'This field is mandatory';
                        }
                      },
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  ButtonSimple(
                    onTap: _validate,
                    color: Colors.cyan[200],
                    icon: Icons.check,
                    text: 'Confirm',
                  ),
                  const SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 15.0,
                    ),
                  ),
                  if (loading) LoadingCircle(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

