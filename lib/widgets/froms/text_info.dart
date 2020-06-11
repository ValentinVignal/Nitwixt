import 'package:flutter/material.dart';

enum TextInfoMode { show, edit, blocked }

class TextInfo extends StatelessWidget {
  final String title;
  final String value;
  final TextInfoMode mode;
  final double fontSize;
  final Function onChanged;
  final Function validator;
  final TextEditingController controller;

  TextStyle textStyleInfo;
  TextStyle textStyleTitle;
  TextStyle textStyleValue;

  TextInfo({
    this.title,
    this.value,
    this.mode = TextInfoMode.show,
    this.fontSize = 20.0,
    this.onChanged,
    this.validator,
    this.controller,
  }) : super() {
    textStyleInfo = TextStyle(
      fontSize: this.fontSize,
      color: Colors.white,
    );
    textStyleTitle = textStyleInfo;
    textStyleValue = textStyleInfo.copyWith(
      color: Colors.grey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(this.title, style: textStyleTitle)),
        Builder(
          builder: (BuildContext buildContext) {
            bool enable = this.mode == TextInfoMode.edit;
            bool formFieldStyle = this.mode != TextInfoMode.show;
            return Expanded(
              child: TextFormField(
                enabled: enable,
                initialValue: this.value,
                style: enable ? textStyleTitle : textStyleValue,
                decoration: InputDecoration(
                  hintText: this.value,
                  hintStyle: TextStyle(color: Colors.grey[800]),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),
                  errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                ),
                onChanged: this.onChanged,
                validator: this.validator,
                controller: controller,
              ),
            );
          },
        ),
      ],
    );
  }
}
