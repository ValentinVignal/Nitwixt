import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

void copy(String text) {
  Clipboard.setData(ClipboardData(text: text));
  Fluttertoast.showToast(
    msg: 'Copied',
  );
}