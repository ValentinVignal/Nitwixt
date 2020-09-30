import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/services/database/database.dart';
import 'package:nitwixt/widgets/widgets.dart';
import 'package:nitwixt/shared/constants.dart';

class DeleteChatDialog extends StatefulWidget {
  const DeleteChatDialog({
    @required this.chat,
    this.members,
  }) : super();

  final models.Chat chat;
  final Map<String, models.User> members;

  @override
  _DeleteChatDialogState createState() => _DeleteChatDialogState();
}

class _DeleteChatDialogState extends State<DeleteChatDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String inputFromUser = '';

  String error = '';

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final DatabaseChat _databaseChat = DatabaseChat(id: widget.chat.id);
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
                Text(
                  'To Delete the chat',
                  style: TextStyle(color: Colors.red[900], fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
                FutureBuilder<String>(
                  future: widget.chat.nameToDisplay(user),
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return LoadingDots(
                        color: Colors.grey,
                        fontSize: 18.0,
                      );
                    } else {
                      if (snapshot.hasError) {
                        return const Text(
                          'Could not display name',
                          style: TextStyle(color: Colors.red, fontSize: 18.0),
                        );
                      } else {
                        return Text(snapshot.data, style: const TextStyle(color: Colors.white, fontSize: 18.0));
                      }
                    }
                  },
                ),
                Text(
                  'Write "DELETE" and press the delete button',
                  style: TextStyle(color: Colors.red[900], fontSize: 18.0),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextFormField(
                  initialValue: inputFromUser,
                  decoration: textInputDecoration.copyWith(
                    hintText: 'DELETE',
                  ),
                  style: const TextStyle(color: Colors.white),
                  validator: (String val) {
                    return val == 'DELETE' ? null : 'Enter "DELETE"';
                  },
                  onChanged: (String val) {
                    setState(() => inputFromUser = val);
                  },
                ),
                const SizedBox(height: 20.0),
                if (isLoading)
                  LoadingCircle()
                else
                  Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20.0),
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
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            await _databaseChat.delete(members: widget.members.values.toList());
                            int count = 0;
                            Navigator.of(context).popUntil((_) => count++ >= 2); // Come back 3 windows
                          } catch (e) {
                            print(e);
                            setState(() {
//                              error = e.toString();
                              error = 'Could not delete the chat';
                            });
                            setState(() {
                              isLoading = false;
                            });
                          }
                        }
                      },
                      text: 'Delete',
                      icon: Icons.delete,
                      color: Colors.red[900],
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
