import 'package:flutter/material.dart';
import 'package:nitwixt/models/user.dart';
import 'package:nitwixt/models/user_auth.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/shared/constants.dart';
import 'package:nitwixt/shared/loading.dart';

class AccountInfo extends StatefulWidget {
  final bool isEditing;
  AccountInfo({
    this.isEditing = false,
  }) : super();

  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {

  String _enterredName;

  @override
  Widget build(BuildContext context) {
    final userAuth = Provider.of<UserAuth>(context);
    final user = Provider.of<User>(context);

    return Container(
      child: Form(
        child: ListView(
          padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
          children: <Widget>[
            // Username
            TextInfo(
              title: 'Username',
              value: user.username,
              mode: widget.isEditing ? TextInfoMode.blocked : TextInfoMode.show,
            ),
            // Name
            SizedBox(height: 10.0),
            TextInfo(
              title: 'Name',
              value: user.name,
              mode: widget.isEditing ? TextInfoMode.edit : TextInfoMode.show,
              onChanged: (val) {
                setState(() {
                  _enterredName = val;
                });
              },
            ),
            SizedBox(height: 10.0),
            TextInfo(
              title: 'Email',
              value: userAuth.email,
              mode: widget.isEditing ? TextInfoMode.blocked : TextInfoMode.show,
            ),
          ],
        ),
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
        Expanded (child: Text(this.title, style: textStyleTitle)),
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
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue)
                  ),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blueGrey)
                  ),
                  errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red)
                  ),
                ),
                onChanged: this.onChanged,
                validator: this.validator,
              ),
            );
          },
        ),
      ],
    );
  }
}
