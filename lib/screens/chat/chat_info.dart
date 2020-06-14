import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/screens/chat/delete_chat_dialog.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/widgets/widgets.dart';

class ChatInfo extends StatefulWidget {
  @override
  _ChatInfo createState() => _ChatInfo();
}

class _ChatInfo extends State<ChatInfo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _textControllerName = TextEditingController();
  final ListInputController _listInputController = ListInputController();

  bool _isEditing = false;
  bool loading = false;
  String error = '';

  @override
  void dispose() {
    _textControllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final models.Chat chat = Provider.of<models.Chat>(context);
    final List<models.User> members = Provider.of<List<models.User>>(context);
    final models.User user = Provider.of<models.User>(context);

    if (!_isEditing) {
      _textControllerName.text = chat.name;
    }
    final database.DatabaseChat _databaseChat = database.DatabaseChat(chatId: chat.id);

    void _showDeleteChatPanel() {
      showDialog(
        context: context,
        builder: ((BuildContext contextDialog) {
          return DeleteChatDialog(
            chat: chat,
            members: members,
          );
        }),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: chat.nameToDisplay(user),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingDots(
                color: Colors.grey,
                fontSize: 18.0,
              );
            } else {
              if (snapshot.hasError) {
                return Text(
                  'Could not display name',
                  style: TextStyle(color: Colors.red, fontSize: 18.0),
                );
              } else {
                return Text(snapshot.data, style: TextStyle(color: Colors.white, fontSize: 18.0));
              }
            }
          },
        ),
        backgroundColor: Colors.black,
        leading: new IconButton(
          icon: Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isEditing ? Icons.done : Icons.edit),
            onPressed: () async {
              if (_isEditing && (user.name != _textControllerName.text.trim() || _listInputController.isNotEmpty)) {
                if (_formKey.currentState.validate()) {
                  setState(() {
                    loading = true;
                  });
                  try {
                    // * ----- Name -----
                    if (user.name != _textControllerName.text.trim()) {
                      await _databaseChat.update({
                        'name': _textControllerName.text.trim(),
                      });
                      setState(() {
                        _textControllerName.text = user.name;
                      });
                    }
                    // * ----- Members -----
                    if (_listInputController.isNotEmpty) {
                      List<String> allUsernames = _listInputController.values +
                          members.map<String>((models.User user) {
                            return user.username;
                          }).toList();
                      await database.DatabaseChat(chatId: chat.id).updateMembers(allUsernames);
                    }
                    setState(() {
                      _isEditing = false;
                      error = '';
                    });
                  } catch (err) {
                    print('err $err');
                    setState(() {
                      error = err.toString();
//                      error = 'Could not update the profile';
                    });
                  }
                  setState(() {
                    loading = false;
                  });
                }
              } else {
                setState(() {
                  _isEditing = !_isEditing;
                });
              }
            },
          ),
          _isEditing
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                    });
                  },
                )
              : SizedBox(
                  width: 0.0,
                ),
        ],
      ),
//      body: isEditing ? AccountEdit() : AccountInfo(),
      body: Stack(
        children: <Widget>[
          Container(
            child: Form(
              key: _formKey,
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                children: <Widget>[
                  error.isEmpty
                      ? SizedBox(
                          height: 0.0,
                        )
                      : Text(
                          error,
                          style: TextStyle(color: Colors.red),
                        ),
                  // Name
                  SizedBox(height: error.isEmpty ? 0.0 : 10.0),
                  TextInfo(
                    title: 'Name',
                    mode: _isEditing ? TextInfoMode.edit : TextInfoMode.show,
                    controller: _textControllerName,
                    scrollDirection: Axis.horizontal,
                  ),
                  Divider(
                    color: Colors.blueGrey,
                  ),
                  Text(
                    'Members',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    itemBuilder: (contextList, index) {
                      String username_ = members[index].id == user.id ? '(@You) ${members[index].username}' : members[index].username;
                      return TextInfoSubtitle(
                        title: username_,
                        mode: TextInfoMode.show,
                        value: members[index].name,
                        scrollDirection: Axis.horizontal,
                      );
                    },
                  ),
                  _isEditing
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ListInput(
                              controller: _listInputController,
                              physics: NeverScrollableScrollPhysics(),
                              hintText: 'Username',
                              validator: (val) {
                                if (val.trim().isEmpty) {
                                  return 'Enter username';
                                } else if (val == user.username) {
                                  return 'Enter another username than yours';
                                } else if (members
                                    .map((models.User member) {
                                      return member.username;
                                    })
                                    .toList()
                                    .contains(val)) {
                                  return '"$val" is already in the chat';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 100.0),
                            Divider(
                              color: Colors.red[900],
                            ),
                            Container(
//                        padding: EdgeInsets.symmetric(
//                          vertical: 10.0,
//                          horizontal: 10.0,
//                        ),
//                        decoration: BoxDecoration(
//                          border: Border.all(
//                            color: Colors.red[900],
//                            width: 2.0,
//                          ),
//                          borderRadius: BorderRadius.circular(20.0),
//                        ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: Icon(
                                            Icons.warning,
                                            color: Colors.red[900],
                                            size: 20.0,
                                          ),
                                        ),
                                        TextSpan(
                                          text: '   Danger Zone   ',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[900],
                                            fontSize: 20.0,
                                          ),
                                        ),
                                        WidgetSpan(
                                          child: Icon(
                                            Icons.warning,
                                            color: Colors.red[900],
                                            size: 20.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 20.0),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      ButtonSimple(
                                        color: Colors.red[900],
                                        text: 'Delete Chat',
                                        icon: Icons.delete,
                                        onTap: () {
                                          _showDeleteChatPanel();
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        )
                      : SizedBox(height: 0.0),
                ],
              ),
            ),
          ),
          loading ? LoadingCircle() : SizedBox(width: 0.0, height: 0.0),
        ],
      ),
    );
  }
}
