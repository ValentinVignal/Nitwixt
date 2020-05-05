import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:textwit/screens/start.dart';
import 'package:textwit/services/auth.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart' as scf;
import 'package:textwit/screens/stream_chat/stream_chat.dart';

import 'models/user.dart';

void main() async {
  final client = scf.Client(
    'b67pax5b2wdq',
    logLevel: scf.Level.INFO,
  );

  await client.setUser(
    scf.User(id: 'frosty-band-5'),
    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VyX2lkIjoiZnJvc3R5LWJhbmQtNSJ9.ivA1qnzwJWxwAstbCqqRgNPYgfi2fz4KMcR4R_hj3qg',
  );

  final channel = client.channel('messaging', id: 'godevs');

  // ignore: unawaited_futures
  channel.watch();

  runApp(MyAppScf(client, channel));
//  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserAuth>.value(
        value: AuthService().user,
        child: MaterialApp(
          home: Start(),
        ));
  }
}
