import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
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

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: chat.nameToDisplay(user),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text(
                '...',
                style: TextStyle(color: Colors.grey, fontSize: 18.0),
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
        backgroundColor: Colors.blueGrey[800],
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
                    if(user.name != _textControllerName.text.trim()) {
                      await _databaseChat.update({
                        'name': _textControllerName.text.trim(),
                      });
                      setState(() {
                        _textControllerName.text = user.name;
                      });
                    }
                    // * ----- Members -----
                    if (_listInputController.isNotEmpty) {
                      List<String> allUsernames = _listInputController.values + members.map<String>((models.User user) {
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
                      error = 'Could not update the profile';
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
        ],
      ),
//      body: isEditing ? AccountEdit() : AccountInfo(),
      body: Stack(
        children: <Widget>[
          loading ? LoadingCircle() : SizedBox(width: 0.0, height: 0.0),
          Container(
            child: Form(
              key: _formKey,
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
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
                      return TextInfo(
                        title: username_,
                        mode: _isEditing ? TextInfoMode.blocked : TextInfoMode.show,
                        value: members[index].name,
                      );
                    },
                  ),
                  _isEditing ? ListInput(
                    controller: _listInputController,
                    physics: NeverScrollableScrollPhysics(),
                    hintText: 'Username',
                    validator: (val) {
                      if (val.trim().isEmpty) {
                        return 'Enter username';
                      } else if (val == user.username) {
                        return 'Enter another username than yours';
                      } else if (members.map((models.User member) {
                        return member.username;
                      }).toList().contains(val)) {
                        return '"$val" is already in the chat';
                      }
                      return null;
                    },
                  ) : SizedBox(height: 0.0),
                  SizedBox(height: 10.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
