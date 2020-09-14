import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/chats/chat_picture.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';

import 'delete_chat_dialog.dart';

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

  final ImagePicker _imagePicker = ImagePicker();
  File image;

  @override
  void dispose() {
    _textControllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final models.Chat chat = Provider.of<models.Chat>(context);
    final Map<String, models.User> members = Provider.of<Map<String, models.User>>(context);
    final models.User user = Provider.of<models.User>(context);

    if (!_isEditing) {
      _textControllerName.text = chat.name;
    }
    final database.DatabaseChat _databaseChat = database.DatabaseChat(chatId: chat.id);

    void _showDeleteChatPanel() {
      showDialog<DeleteChatDialog>(
        context: context,
        builder: (BuildContext contextDialog) {
          return DeleteChatDialog(
            chat: chat,
            members: members,
          );
        },
      );
    }

    bool _hasChanges() {
      return _isEditing && (user.name != _textControllerName.text.trim() || _listInputController.isNotEmpty || image != null);
    }

    Future<void> _applyChanges() async {
      if (_hasChanges()) {
        if (_formKey.currentState.validate()) {
          setState(() {
            loading = true;
          });
          try {
            // * ----- Name -----
            if (user.name != _textControllerName.text.trim()) {
              await _databaseChat.update(<String, String>{
                models.ChatKeys.name: _textControllerName.text.trim(),
              });
              setState(() {
                _textControllerName.text = user.name;
              });
            }
            // * ----- Members -----
            if (_listInputController.isNotEmpty) {
              final List<String> allUsernames = _listInputController.values +
                  members.values.map<String>((models.User user) {
                    return user.username;
                  }).toList();
              await database.DatabaseChat(chatId: chat.id).updateMembers(allUsernames);
            }
            // * ----- Image -----
            if (image != null) {
              database.DatabaseFiles(path: chat.picturePath).uploadFile(image);
              chat.emptyPictureUrl();
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
    }

    void _cancelChanges() {
      setState(() {
        _isEditing = false;
      });
    }

    Future<void> getImage() async {
      final PickedFile tempImage = await _imagePicker.getImage(source: ImageSource.gallery);
      setState(() {
        image = File(tempImage.path);
      });
    }

    final Widget imageWidget = Center(
      child: Stack(
        children: <Widget>[
          if (image != null)
            CircleAvatar(
              backgroundImage: Image.file(image).image,
              radius: 40,
            )
          else
            ChatPicture(
              chat: chat,
              user: user,
              size: 40.0,
            ),
          if (_isEditing)
            IconButton(
              enableFeedback: _isEditing,
              icon: const Icon(
                Icons.edit,
                color: Colors.grey,
              ),
              onPressed: _isEditing ? getImage : null,
            )
        ],
      ),
    );

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
                return const Text(
                  'Could not display name',
                  style: TextStyle(color: Colors.red, fontSize: 18.0),
                );
              } else {
                return Text(
                  snapshot.data,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                );
              }
            }
          },
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(_isEditing ? Icons.done : Icons.edit),
            onPressed: _applyChanges,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _cancelChanges,
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
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                children: <Widget>[
                  if (error.isNotEmpty)
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  // Name
                  SizedBox(height: error.isEmpty ? 0.0 : 10.0),
                  imageWidget,
                  const SizedBox(height: 10.0),
                  TextInfo(
                    title: 'Name',
                    mode: _isEditing ? TextInfoMode.edit : TextInfoMode.show,
                    controller: _textControllerName,
                    scrollDirection: Axis.horizontal,
                  ),
                  const Divider(
                    color: Colors.blueGrey,
                  ),
                  const Text(
                    'Members',
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 20.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: members.length,
                    itemBuilder: (BuildContext contextList, int index) {
                      final models.User member = members.values.toList()[index];
                      final String username_ = member.id == user.id ? '(@You) ${member.username}' : member.username;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            child: UserPicture(
                              user: member,
                              size: 20.0,
                            ),
                            padding: const EdgeInsets.all(5.0),
                          ),
                          Flexible(
                            child: TextInfoSubtitle(
                              title: username_,
                              mode: TextInfoMode.show,
                              value: member.name,
                              scrollDirection: Axis.horizontal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  if (_isEditing)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        ListInput(
                          controller: _listInputController,
                          physics: const NeverScrollableScrollPhysics(),
                          hintText: 'Username',
                          validator: (String val) {
                            if (val.trim().isEmpty) {
                              return 'Enter username';
                            } else if (val == user.username) {
                              return 'Enter another username than yours';
                            } else if (members.values
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
                        const SizedBox(height: 100.0),
                        Divider(
                          color: Colors.red[900],
                        ),
                        Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              RichText(
                                text: TextSpan(
                                  children: <InlineSpan>[
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
                              const SizedBox(height: 20.0),
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
                ],
              ),
            ),
          ),
          if (loading) LoadingCircle(),
        ],
      ),
    );
  }
}
