import 'package:flutter/material.dart';
import 'package:nitwixt/models/user.dart';
import 'package:nitwixt/models/user_auth.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart' as database;
import 'package:nitwixt/shared/loading.dart';

class Account extends StatefulWidget {
  @override
  _AccountState createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _textControllerName = TextEditingController();

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
    final userAuth = Provider.of<UserAuth>(context);
    final user = Provider.of<User>(context);
    if (!_isEditing) {
      _textControllerName.text = user.name;
    }
    final database.DatabaseUser _databaseUser = database.DatabaseUser(id: user.id);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('Account'),
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
              if (_isEditing && user.name != _textControllerName.text.trim() ) {
                if (_formKey.currentState.validate()) {
                  setState(() {
                    loading = true;
                  });
                  await _databaseUser.update({
                    'name': _textControllerName.text.trim(),
                  }).then((res) {
                    setState(() {
                      _textControllerName.text = user.name;
                      _isEditing = false;
                      error = '';
                    });
                  }).catchError((err) {
                    setState(() {
                      error = 'Could not update the profile';
                    });
                  });
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
          loading ? Loading() : SizedBox(width: 0.0, height: 0.0),
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
                  ),
                  SizedBox(height: 10.0),
                  TextInfo(
                    title: 'Email',
                    value: userAuth.email,
                    mode: _isEditing ? TextInfoMode.blocked : TextInfoMode.show,
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

enum TextInfoMode { show, edit, blocked }

class TextInfo extends StatelessWidget {
  final String title;
  final String value;
  final TextInfoMode mode;
  final double fontSize;
  final Function onChanged;
  final Function validator;
  final TextEditingController controller;

  TextStyle textStyleInfo;
  TextStyle textStyleTitle;
  TextStyle textStyleValue;

  TextInfo({
    this.title,
    this.value,
    this.mode = TextInfoMode.show,
    this.fontSize = 20.0,
    this.onChanged,
    this.validator,
    this.controller,
  }) : super() {
    textStyleInfo = TextStyle(
      fontSize: this.fontSize,
      color: Colors.white,
    );
    textStyleTitle = textStyleInfo;
    textStyleValue = textStyleInfo.copyWith(
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(this.title, style: textStyleTitle)),
        Builder(
          builder: (BuildContext buildContext) {
            bool enable = this.mode == TextInfoMode.edit;
            bool formFieldStyle = this.mode != TextInfoMode.show;
            return Expanded(
              child: TextFormField(
                enabled: enable,
                initialValue: this.value,
                style: enable ? textStyleTitle : textStyleValue,
                decoration: InputDecoration(
                  hintText: this.value,
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                ),
                onChanged: this.onChanged,
                validator: this.validator,
                controller: controller,
              ),
            );
          },
        ),
      ],
    );
  }
}
