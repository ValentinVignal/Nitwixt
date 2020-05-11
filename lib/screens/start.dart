import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/screens/authenticate/verify_email.dart';
import 'package:nitwixt/screens/home/user_provider.dart';
import 'authenticate/authenticate.dart';
import 'package:flutter/foundation.dart' as foundation;

import 'package:nitwixt/models/models.dart' as models;

class Start extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final models.UserAuth userAuth = Provider.of<models.UserAuth>(context);

    if (userAuth == null) {
      // If there is no user, we need to sign in or register
      return MaterialApp(
        home: Authenticate(),
      );
    } else if (foundation.kReleaseMode && !userAuth.isEmailVerified) {
      // Because I don't want to validate a huge number of dummy email to debug
      // foundation.kReleaseMode: true on release app and false on debug app
      return MaterialApp(
        home: VerifyEmail(),
      );
    } else {
      // If there is a user, connect
      return UserProvider();
    }
  }
}
