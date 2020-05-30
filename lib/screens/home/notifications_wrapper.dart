import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nitwixt/screens/home/home.dart';

class NotificationsWrapper extends StatefulWidget {
  @override
  _NotificationsWrapperState createState() => _NotificationsWrapperState();
}

class _NotificationsWrapperState extends State<NotificationsWrapper> {
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
      print('onMessage: $message');
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

    firebaseMessaging.getToken().then((token) {
      print('token $token');
//      Firestore.instance.collection('users').document(currentUserId).updateData({'pushToken': token});
//    }).catchError((err) {
//      Fluttertoast.showToast(msg: err.message.toString());
    });     // TODO: Put it
  }

  configLocalNotification() {
    var initializationSettingsAndroid = new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = new IOSInitializationSettings();
    var initializationSettings = new InitializationSettings(initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      Platform.isAndroid ? 'com.valentinvignal.nitwixt' : 'com.valentinvignal.nitwixt',
      'Flutter chat demo',
      'Yout channel description',
      playSound: true,
      enableVibration: true,
      enableLights: true,
      importance: Importance.Max,
      priority: Priority.High,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    print('message showNotification $message');

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
    return Home();
  }
}
