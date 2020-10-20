import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nitwixt/screens/home/home.dart';
import 'package:nitwixt/models/models.dart' as models;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nitwixt/screens/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:nitwixt/services/database/database.dart' as database;

class NotificationsWrapper extends StatefulWidget {
  const NotificationsWrapper({
    @required this.user,
  }) : super();

  final models.User user;

  @override
  _NotificationsWrapperState createState() => _NotificationsWrapperState(user: user);
}

class _NotificationsWrapperState extends State<NotificationsWrapper> {
  _NotificationsWrapperState({
    @required this.user,
  });

  final models.User user;
  models.PushToken pushToken;

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    registerNotification();
    configLocalNotification();
  }

  void registerNotification() {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> message) {
      Platform.isAndroid ? showNotification(message['notification']) : showNotification(message['aps']['alert']);
      return;
    }, onResume: (Map<String, dynamic> message) {
      Platform.isAndroid ? showNotification(message['notification']) : showNotification(message['aps']['alert']);
      print('onResume $message');
      return;
    }, onLaunch: (Map<String, dynamic> message) {
      Platform.isAndroid ? showNotification(message['notification']) : showNotification(message['aps']['alert']);
      print('onLaunch $message');
      return;
    });
  }

  void configLocalNotification() {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(dynamic message) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid ? 'com.valentinvignal.nitwixt' : 'com.valentinvignal.nitwixt',
      'Flutter chat demo',
      'Yout channel description',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    const IOSNotificationDetails iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final NotificationDetails platformChannelSpecifics = NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    // print('message showNotification $message');

    await flutterLocalNotificationsPlugin.show(
      0,
      message['title'].toString(),
      message['body'].toString(),
      platformChannelSpecifics,
      payload: 'hello',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureProvider<models.PushToken>.value(
      value: firebaseMessaging.getToken().then<models.PushToken>((String token) async {
        // print('token $token');
        pushToken = models.PushToken(current: token);
        await database.DatabasePushToken(id: user.id).newToken(token);
        return pushToken;
      }).catchError((dynamic err) {
        print('err $err');
        Fluttertoast.showToast(msg: err.toString());
      }),
      child: PushTokenReceiver(),
    );
  }
}

class PushTokenReceiver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final models.PushToken pushToken = Provider.of<models.PushToken>(context);

    if (pushToken == null) {
      return LoadingScreen();
    } else {
      return Home();
    }
  }
}
