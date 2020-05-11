import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/screens/start.dart';
import 'package:nitwixt/services/auth.dart';

import 'models/user_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserAuth>.value(
      // * Provides the UserAuth to all the app
      value: AuthService().user,
      child: Start(),
    );
  }
}
