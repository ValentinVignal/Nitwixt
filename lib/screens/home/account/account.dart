import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nitwixt/models/user.dart';
import 'package:nitwixt/models/user_auth.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  // * -------------------- Attributes -----------------------------

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _textControllerName = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  File image;

  bool _isEditing = false;
  bool loading = false;
  String error = '';

  @override
  void dispose() {
    _textControllerName.dispose();
    super.dispose();
  }

  Future<void> getImage() async {
    final PickedFile tempImage = await _imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      image = File(tempImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    // * -------------------- Attributes -----------------------------

    final UserAuth userAuth = Provider.of<UserAuth>(context);
    final User user = Provider.of<User>(context);
    if (!_isEditing) {
      _textControllerName.text = user.name;
    }
    final database.DatabaseUser _databaseUser = database.DatabaseUser(id: user.id);

    // * -------------------- Functions -----------------------------

    bool hasAChange() {
      return (user.name != _textControllerName.text.trim()) || (image != null);
    }

    Future<void> confirmChanges() async {
      if (_isEditing && hasAChange()) {
        try {
          if (_formKey.currentState.validate()) {
            setState(() {
              loading = true;
            });
            // * ----- Name -----
            if (user.name != _textControllerName.text.trim()) {
              await _databaseUser.update({
                UserKeys.name: _textControllerName.text.trim(),
              });
            }
            // * ----- Image -----
            if (image != null) {
              await database.DatabaseFiles(path: user.picturePath).uploadFile(image);
              user.emptyPictureUrl(reload: true);
            }

            setState(() {
              _textControllerName.text = user.name;
              _isEditing = false;
              error = '';
            });
          }
        } catch (err) {
          setState(() {
            error = 'Could not update the profile';
          });
        }
        setState(() {
          loading = false;
        });
      } else {
        setState(() {
          _isEditing = !_isEditing;
        });
      }
    }

    void cancelChanges() {
      setState(() {
        _isEditing = false;
        image = null;
      });
    }

    // * -------------------- Widgets -----------------------------

    final Widget imageWidget = Center(
      child: Stack(
        children: <Widget>[
          if (image != null)
            CircleAvatar(
              backgroundImage: Image.file(image, height: 200, width: 200.0).image,
              radius: 50,
            )
          else
            UserPicture(
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
            ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Account'),
//        backgroundColor: Colors.blueGrey[800],
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
            onPressed: confirmChanges,
          ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: cancelChanges,
            ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          if (loading) LoadingCircle(),
          Container(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
                children: <Widget>[
                  if (error.isNotEmpty)
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  imageWidget,
                  // Username
                  TextInfo(
                    title: 'Username',
                    value: user.username,
                    mode: _isEditing ? TextInfoMode.blocked : TextInfoMode.show,
                  ),
                  // Name
                  const SizedBox(height: 10.0),
                  TextInfo(
                    title: 'Name',
                    mode: _isEditing ? TextInfoMode.edit : TextInfoMode.show,
                    validator: (String val) {
                      if (val.trim().isEmpty) {
                        return 'Enter your name';
                      }
                      return null;
                    },
                    controller: _textControllerName,
                    scrollDirection: Axis.horizontal,
                  ),
                  const SizedBox(height: 10.0),
                  TextInfo(
                    title: 'Email',
                    value: userAuth.email,
                    mode: _isEditing ? TextInfoMode.blocked : TextInfoMode.show,
                    scrollDirection: Axis.horizontal,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
