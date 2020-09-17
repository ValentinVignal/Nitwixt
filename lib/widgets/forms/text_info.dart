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
      fontSize: fontSize,
      color: Colors.white,
    );
    textStyleTitle = textStyleInfo;
    textStyleValue = textStyleInfo.copyWith(
      color: Colors.grey,
    );
    if (scrollDirection == Axis.horizontal) {
      maxLines = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(title, style: textStyleTitle)),
        Expanded(
          child: Builder(
            builder: (BuildContext buildContext) {
              final bool enable = mode == TextInfoMode.edit;
              if (mode == TextInfoMode.show) {
                final Text textWidget = Text(
                  value ?? controller.text,
                  style: textStyleValue,
                  textAlign: TextAlign.left,
                  maxLines: scrollDirection != null ? null : maxLines,
                );
                if (scrollDirection == null) {
                  // Not scrollable
                  return textWidget;
                } else {
                  final Widget scrollableWidget =  SingleChildScrollView(
                    scrollDirection: scrollDirection,
                    child: textWidget,
                  );
                  if (scrollDirection == Axis.horizontal) {
                    return scrollableWidget;
                  } else {
                    return Container(
                      constraints: BoxConstraints(
                        maxHeight: 1.1 * fontSize * maxLines,
                      ),
                      child: scrollableWidget,
                    );
                  }
                }
              } else {
                return TextFormField(
                  minLines: 1,
                  maxLines: maxLines,
                  enabled: enable,
                  initialValue: value,
                  style: enable ? textStyleTitle : textStyleValue,
                  keyboardType: maxLines == 1 ? TextInputType.text : TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration.collapsed(
                    hintText: value,
                    hintStyle: TextStyle(color: Colors.grey[800]),
                  ).copyWith(
                    isDense: true,
                    focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                    enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueGrey)),
                    errorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                    focusedErrorBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
                  ),
                  onChanged: onChanged,
                  validator: validator,
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
