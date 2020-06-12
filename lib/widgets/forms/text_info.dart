import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'text_info_mode.dart';

class TextInfo extends StatelessWidget {
  final String title;
  final String value;
  final TextInfoMode mode;
  final double fontSize;
  final Function onChanged;
  final Function validator;
  final TextEditingController controller;
  int maxLines;
  final Axis scrollDirection;

  TextStyle textStyleInfo;
  TextStyle textStyleTitle;
  TextStyle textStyleValue;

  TextInfo({
    this.title,
    this.value,
    this.mode = TextInfoMode.show,
    this.fontSize = 17.0,
    this.onChanged,
    this.validator,
    this.controller,
    this.maxLines,
    this.scrollDirection,
  }) : super() {
    assert(value == null || controller == null);
    assert(!((maxLines == null) && (scrollDirection == Axis.vertical)));
    textStyleInfo = TextStyle(
      fontSize: this.fontSize,
      color: Colors.white,
    );
    textStyleTitle = textStyleInfo;
    textStyleValue = textStyleInfo.copyWith(
      color: Colors.grey,
    );
    if (scrollDirection == Axis.horizontal) {
      this.maxLines = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(this.title, style: textStyleTitle)),
        Expanded(
          child: Builder(
            builder: (BuildContext buildContext) {
              bool enable = this.mode == TextInfoMode.edit;
              bool formFieldStyle = this.mode != TextInfoMode.show;
              if (this.mode == TextInfoMode.show) {
                Text textWidget = Text(
                  this.value ?? this.controller.text,
                  style: this.textStyleValue,
                  textAlign: TextAlign.left,
                  maxLines: this.scrollDirection != null ? null : this.maxLines,
                );
                if (this.scrollDirection == null) {
                  // Not scrollable
                  return textWidget;
                } else {
                  Widget scrollableWidget =  SingleChildScrollView(
                    scrollDirection: this.scrollDirection,
                    child: textWidget,
                  );
                  if (this.scrollDirection == Axis.horizontal) {
                    return scrollableWidget;
                  } else {
                    return Container(
                      constraints: BoxConstraints(
                        maxHeight: 1.1 * this.fontSize * this.maxLines,
                      ),
                      child: scrollableWidget,
                    );
                  }
                }
              } else {
                return TextFormField(
                  minLines: 1,
                  maxLines: this.maxLines,
                  enabled: enable,
                  initialValue: this.value,
                  style: enable ? textStyleTitle : textStyleValue,
                  keyboardType: this.maxLines == 1 ? TextInputType.text : TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration.collapsed(
                    hintText: this.value,
                    hintStyle: TextStyle(color: Colors.grey[800]),
                  ).copyWith(
                    isDense: true,
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),
                    errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                    focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  ),
                  onChanged: this.onChanged,
                  validator: this.validator,
                  controller: controller,
                );

              }
            },
          ),
        ),
      ],
    );
  }
}
