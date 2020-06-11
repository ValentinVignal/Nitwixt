import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/chat/chat_home.dart';
import 'package:nitwixt/screens/chat/chat_provider.dart';
import 'package:nitwixt/shared/loading.dart';
import 'package:nitwixt/widgets/button_simple.dart';
import 'package:nitwixt/widgets/froms/forms.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart' as database;

class NewChatDialog extends StatefulWidget {
  @override
  _NewChatDialogState createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String error = '';
  bool isLoading = false;

  ListInputController listInputController = ListInputController(values: List<String>.from(['']));

  List<String> duplicatedUsernames() {
    List<String> _duplicatedUsernames = new List<String>();
    listInputController.values.forEach((String username) {
      if (listInputController.values.indexOf(username) != listInputController.values.lastIndexOf(username) &&
          !_duplicatedUsernames.contains(username)) {
        _duplicatedUsernames.add(username);
      }
    });
    return _duplicatedUsernames;
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      backgroundColor: Color(0xFF202020),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
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
                ListInput(
                  controller: listInputController,
                  physics: NeverScrollableScrollPhysics(),
                  hintText: 'Username',
                  validator: (val) {
                    if (val.trim().isEmpty) {
                      return 'Enter username';
                    } else if (val == user.username) {
                      return 'Enter another username than yours';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.0),
                isLoading
                    ? Loading()
                    : Text(
                        error,
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ButtonSimple(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icons.close,
                      text: 'Cancel',
                      fontSize: 15.0,
                    ),
                    SizedBox(width: 5.0),
                    ButtonSimple(
                      onTap: () async {
                        if (_formKey.currentState.validate()) {
                          // Test if a username is entered twice
                          List<String> duplicatedEnterredUsernames = duplicatedUsernames();
                          if (duplicatedEnterredUsernames.isNotEmpty) {
                            // Duplicates
                            setState(() {
                              error = 'Username(s) ${duplicatedEnterredUsernames.join(', ')} entered several times';
                            });
                          } else {
                            // No duplicates
                            setState(() {
                              error = '';
                              isLoading = true;
                            });
                            try {

                              String chatId = await database.DatabaseChat.createNewChat(listInputController.values + [user.username]);
                              setState(() {
                                isLoading = false;
                                error = '';
                              });
                              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (contextMaterialRoute) {
                                return ChatProvider(
                                  id: chatId,
                                  child: ChatHome(),
                                );
                              }));
                            } catch (err) {
                              setState(() {
                                isLoading = false;
                                error = err;
                              });
                            }
                          }
                        }
                      },
                      text: 'Create',
                      icon: Icons.done,
                      color: Colors.green,
                      fontSize: 15.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
