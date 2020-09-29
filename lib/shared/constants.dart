import 'package:flutter/material.dart';

const InputDecoration textInputDecoration = InputDecoration(
//  fillColor: Color(0x05FFFFFF),
//  filled: true,
  enabledBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.blue),
  ),
  focusedBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.greenAccent, width: 2.0),
  ),
  errorBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2.0),
  ),
  focusedErrorBorder: UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2.0),
  ),
  hintStyle: TextStyle(color: Colors.grey),
  labelStyle: TextStyle(color: Colors.blue),
  errorMaxLines: 2,
);

const InputDecoration textInputDecorationMessage = InputDecoration(
  fillColor: Colors.black,
  filled: true,
  hintStyle: TextStyle(color: Colors.grey),
  border: InputBorder.none,
  focusedBorder: InputBorder.none,
  enabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
);


bool validateEmail(String value) {
  const Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  final RegExp regex = RegExp(pattern.toString());
  if (!regex.hasMatch(value)) {
    return false;
  } else {
    return true;
  }
}

