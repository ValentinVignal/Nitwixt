import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/services/providers/providers.dart';
import 'package:nitwixt/widgets/button_simple.dart';
import 'package:nitwixt/widgets/forms/forms.dart';
import 'package:nitwixt/widgets/widgets.dart';

import 'chat/chat_home.dart';

class NewChatDialog extends StatefulWidget {
  @override
  _NewChatDialogState createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String error = '';
  bool isLoading = false;

  ListInputController listInputController = ListInputController(values: List<String>.from(<String>['']));

  List<String> duplicatedUsernames() {
    final List<String> _duplicatedUsernames = <String>[];
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
      backgroundColor: const Color(0xFF202020),
      content: Container(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text(
                  'Select the usernames of the members',
                  style: TextStyle(color: Colors.grey, fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10.0),
                ListInput(
                  controller: listInputController,
                  physics: const NeverScrollableScrollPhysics(),
                  hintText: 'Username',
                  validator: (String val) {
                    if (val.trim().isEmpty) {
                      return 'Enter username';
                    } else if (val == user.username) {
                      return 'Enter another username than yours';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10.0),
                if (isLoading)
                  LoadingCircle()
                else
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10.0),
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
                    const SizedBox(width: 5.0),
                    ButtonSimple(
                      onTap: () async {
                        /*
                        TODO(Valentin): Put back function
                        if (_formKey.currentState.validate()) {
                          // Test if a username is entered twice
                          final List<String> duplicatedEnteredUsernames = duplicatedUsernames();
                          if (duplicatedEnteredUsernames.isNotEmpty) {
                            // Duplicates
                            setState(() {
                              error = 'Username(s) ${duplicatedEnteredUsernames.join(', ')} entered several times';
                            });
                          } else {
                            // No duplicates
                            setState(() {
                              error = '';
                              isLoading = true;
                            });
                            try {
                              final String chatId =
                                  await database.DatabaseChatMixin.createNewChat(listInputController.values + <String>[user.username]);
                              setState(() {
                                isLoading = false;
                                error = '';
                              });
                              Navigator.of(context).pushReplacement(MaterialPageRoute<ChatProvider>(builder: (BuildContext contextMaterialRoute) {
                                return ChatProvider(
                                  id: chatId,
                                  child: ChatHome(),
                                );
                              }));
                            } catch (err) {
                              setState(() {
                                isLoading = false;
                                error = err.toString();
                              });
                            }
                          }
                        }

                         */
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
