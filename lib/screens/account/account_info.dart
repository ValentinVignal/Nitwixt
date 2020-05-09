import 'package:flutter/material.dart';
import 'package:textwit/models/user.dart';
import 'package:textwit/models/user_auth.dart';
import 'package:provider/provider.dart';
import 'package:textwit/shared/constants.dart';
import 'package:textwit/shared/loading.dart';

class AccountInfo extends StatefulWidget {
  @override
  _AccountInfoState createState() => _AccountInfoState();
}

class _AccountInfoState extends State<AccountInfo> {
  @override
  Widget build(BuildContext context) {
    final userAuth = Provider.of<UserAuth>(context);
    final user = Provider.of<User>(context);

    return Container(
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        children: <Widget>[
          // Username
          Row(
            children: <Widget>[
              Expanded(child: Text('Username:', style: textStyleInfo)),
              Expanded(
                  child: Text(
                '@' + user.username,
                style: textStyleInfo,
              )),
            ],
          ),
          // Name
          SizedBox(height: 10.0),
          Row(
            children: <Widget>[
              Expanded(
                  child: Text(
                'Name',
                style: textStyleInfo,
              )),
              Expanded(
                  child: Text(
                user.name,
                style: textStyleInfo,
              )),
            ],
          )
        ],
      ),
    );
  }
}
