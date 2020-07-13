import 'package:flutter/material.dart';

final ThemeData theme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.blue,
  accentColor: Colors.blueAccent,
  colorScheme: ColorScheme.dark(
    secondary: Colors.blue,
    onPrimary: Colors.white,
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey[850],
    contentTextStyle: TextStyle(color: Colors.white),
  actionTextColor: Colors.blue,

  ),

  appBarTheme: AppBarTheme(
    brightness: Brightness.dark,
    color: Colors.black,
  ),

  scaffoldBackgroundColor: Colors.grey[900],

  textTheme: TextTheme(
    headline1: TextStyle(color: Colors.white),
    bodyText1: TextStyle(color: Colors.white),
    bodyText2: TextStyle(color: Colors.white),
    subtitle1: TextStyle(color: Colors.grey, fontSize: 14.0,),
  )
);

