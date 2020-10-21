
import 'package:flutter/services.dart';
import 'package:flushbar/flushbar.dart';

final flushbarCopied = Flushbar<dynamic>(
  message: 'Message copied to clipboard',
  flushbarPosition: FlushbarPosition.BOTTOM,
  flushbarStyle: FlushbarStyle.FLOATING,
  borderRadius: 20,
  isDismissible: true,
  duration: Duration(milliseconds: 20),);

Flushbar copyToClipboard(String textToCopy) {
  Clipboard.setData(ClipboardData(text: textToCopy));
  return flushbarCopied;
}
