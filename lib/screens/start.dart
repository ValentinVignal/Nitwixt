import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home.dart';
import 'authenticate/authenticate.dart';

import 'package:textwit/models/models.dart' as models;
import 'package:textwit/services/database/database.dart' as database;

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final user = Provider.of<models.UserAuth>(context);

    if (user == null) {
      // If there is no user, we need to sign in or register
      return MaterialApp(
        home: Authenticate(),
      );
    } else {
      // If there is a user, connect
      return StreamProvider.value(
        // * Provides the User to all the app
        value: database.DatabaseUser(id: user.id).user,
        child: MaterialApp(
          home: Home(),
        ),
      );
    }
  }
}
