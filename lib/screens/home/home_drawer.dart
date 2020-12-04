import 'package:flutter/material.dart';
import 'package:nitwixt/screens/home/account/account.dart';
import 'package:nitwixt/screens/home/settings/settings.dart';
import 'package:nitwixt/services/auth/auth.dart' as auth;
import 'package:nitwixt/models/models.dart' as models;
import 'package:nitwixt/widgets/users/user_picture.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatefulWidget {
  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  ScrollController controller = ScrollController();
  ScrollPhysics physics = const ScrollPhysics();
  final auth.AuthService _auth = auth.AuthService();

  bool isListLarge() {
    return controller.positions.isNotEmpty && physics.shouldAcceptUserOffset(controller.position);
  }

  @override
  Widget build(BuildContext context) {
    final models.User user = Provider.of<models.User>(context);
    final models.UserPushTokens userPushTokens = Provider.of<models.UserPushTokens>(context);

    return Drawer(
      child: Column(
        children: <Widget>[
          Flexible(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: UserPicture(
                            user: user,
                            size: 40,
                          ),
                        ),
                      ),
                      DrawerHeaderCaption(
                        text: user.name,
                      ),
                      DrawerHeaderCaption(
                        text: '@${user.username}',
                      ),
                    ],
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.account_circle),
                  title: const Text('Account'),
                  onTap: () => Navigator.push<Account>(context, MaterialPageRoute<Account>(builder: (BuildContext context) => Account())),
                ),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                  onTap: () => Navigator.of(context).push<Settings>(MaterialPageRoute<Settings>(builder: (BuildContext context) => Settings())),
                ),
              ],
            ),
          ),
          if (!isListLarge())
            ListTile(
              tileColor: Colors.black,
              leading: const Icon(Icons.power_settings_new, color: Colors.red),
              title: const Text('Logout'),
              onTap: () async => await _auth.signOut(userPushTokens: userPushTokens),
            ),
        ],
      ),
    );
  }
}

class DrawerHeaderCaption extends StatelessWidget {
  const DrawerHeaderCaption({
    this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
          bottom: 4.0,
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyText2),
      ),
    );
  }
}
