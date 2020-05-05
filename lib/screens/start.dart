import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/models/user.dart';
import 'package:textwit/services/database.dart';
import 'home/home.dart';
import 'authenticate/authenticate.dart';

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<UserAuth>(context);

    if (user == null) {
      return MaterialApp(
        home: Authenticate(),
      );
    } else {
      return StreamProvider.value(
        value: DatabaseUser(uid: user.id).user,
        child: MaterialApp(
          home: Home(),
        ),
      );
    }
  }
}
