import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:textwit/models/models.dart' as models;
import 'package:textwit/screens/home/home.dart';
import 'package:textwit/screens/home/set_username.dart';
import 'package:textwit/services/database/database.dart' as database;
import 'package:textwit/shared/loading.dart';

class UserProvider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final models.UserAuth userAuth = Provider.of<models.UserAuth>(context);

    database.DatabaseUser databaseUser = database.DatabaseUser(id: userAuth.id);

    return StreamProvider<models.User>.value(
      // * Provides the User to all the app
      value: databaseUser.user,
        child: MaterialApp(
          home: UserReceiver(),
          ),
      );
  }
}

class UserReceiver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final models.User user = Provider.of<models.User>(context);

    if (user == null) {
      // No user yet
      return Scaffold(
        body: Loading(),
        );
    } else if (user.isEmpty()) {
      // No record for now on database, we have to create it
      return SetUsername();
    } else {
      return Home();
    }
  }
}

