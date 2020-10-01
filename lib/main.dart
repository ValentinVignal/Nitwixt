import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:nitwixt/screens/start.dart';
import 'package:nitwixt/services/auth/auth.dart';
import 'package:nitwixt/screens/loading_screen.dart';

import 'models/user_auth.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: AuthService.initialize(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong, please restart Nitwixt');
        } else if (snapshot.connectionState != ConnectionState.done) {
          return MaterialApp(
            home: LoadingScreen(),
          );
        } else {
          return StreamProvider<UserAuth>.value(
            // * Provides the UserAuth to all the app
            value: AuthService().user,
            child: Start(),
          );
        }
      },
    );
  }
}
