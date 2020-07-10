import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nitwixt/models/user.dart';
import 'package:nitwixt/models/user_auth.dart';
import 'package:nitwixt/widgets/profile_picture.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  // * -------------------- Attributs -----------------------------

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

  Future getImage() async {
    PickedFile tempImage = await _imagePicker.getImage(source: ImageSource.gallery);
    setState(() {
      image = File(tempImage.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    // * -------------------- Attributs -----------------------------

    final userAuth = Provider.of<UserAuth>(context);
    final user = Provider.of<User>(context);
    if (!_isEditing) {
      _textControllerName.text = user.name;
    }
    final database.DatabaseUser _databaseUser = database.DatabaseUser(id: user.id);

    // * -------------------- Functions -----------------------------

    bool hasAChange() {
      return (user.name != _textControllerName.text.trim()) || (image != null);
    }

    void confirmChanges() async {
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
              database.DatabaseFile(path: user.profilePicturePath).uploadFile(image);
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

    // * -------------------- Widget -----------------------------

    Widget imageWidget = Center(
      child: Stack(
        children: <Widget>[
          image != null
              ? CircleAvatar(
                  backgroundImage: Image.file(image, height: 200, width: 200.0).image,
                  radius: 50,
                )
              : ProfilePicture(
                  urlAsync: user.profilePictureUrl,
                  size: 40.0,
                ),
          _isEditing
              ? IconButton(
                  enableFeedback: _isEditing,
                  icon: Icon(
                    Icons.edit,
                    color: Colors.grey,
                  ),
                  onPressed: _isEditing ? getImage : null,
                )
              : SizedBox.shrink(),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Account'),
//        backgroundColor: Colors.blueGrey[800],
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
            onPressed: confirmChanges,
          ),
          _isEditing
              ? IconButton(
                  icon: Icon(Icons.close),
                  onPressed: cancelChanges,
                )
              : SizedBox(
                  width: 0.0,
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
                  imageWidget,
                  // Username
                  TextInfo(
                    title: 'Username',
                    value: user.username,
                    mode: _isEditing ? TextInfoMode.blocked : TextInfoMode.show,
                  ),
                  // Name
                  SizedBox(height: 10.0),
                  TextInfo(
                    title: 'Name',
//                    value: user.name,
                    mode: _isEditing ? TextInfoMode.edit : TextInfoMode.show,
                    validator: (val) {
                      if (val.trim().isEmpty) {
                        return 'Enter your name';
                      }
                      return null;
                    },
                    controller: _textControllerName,
                    scrollDirection: Axis.horizontal,
                  ),
                  SizedBox(height: 10.0),
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
