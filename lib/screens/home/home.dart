import 'package:flutter/widgets.dart';
import 'package:nitwixt/screens/home/home_drawer.dart';
import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:nitwixt/screens/home/chat_list.dart';
import 'package:nitwixt/services/auth/auth.dart' as auth;
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/widgets.dart';

import 'new_chat_dialog.dart';

// Get the popup menu item from the option in the enum class
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final auth.AuthService _auth = auth.AuthService();
  ScaffoldState scaffoldState;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void showDisclaimerSnackBar() {
    scaffoldState.showSnackBar(
      SnackBar(
//        backgroundColor: Colors.black,
        duration: const Duration(minutes: 5),
        content: const Text(
            '/!\\ Warning /!\\\nNitwixt is still a young project and I didn\'t spend much time on security and privacy of data.\nPlease don\'t put any sensitive information in this app. :)\nAlso, because of incoming data structure changes, all the data might be deleted soon O:)'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () {
            _scaffoldKey.currentState.removeCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => showDisclaimerSnackBar());
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);

    void _showCreateNewChatPanel() {
      showDialog<Widget>(
        context: context,
        builder: (BuildContext context) {
          return NewChatDialog();
        },
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Nitwixt'),
        elevation: 0.0,
      ),
      drawer: HomeDrawer(),
      body: Builder(
        builder: (BuildContext buildContext) {
          scaffoldState = Scaffold.of(buildContext);
          return user == null ? LoadingCircle() : ChatList();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateNewChatPanel();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
