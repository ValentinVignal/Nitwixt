import 'package:flutter/material.dart';
import 'package:progress_indicators/progress_indicators.dart';

class LoadingDots extends StatelessWidget {
  double fontSize;
  Color color;
  MainAxisAlignment alignment;

  LoadingDots({
    this.fontSize = 16.0,
    this.color = Colors.blueGrey,
    this.alignment = MainAxisAlignment.start
  }) : super();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: this.alignment,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        JumpingDotsProgressIndicator(
          fontSize: this.fontSize,
          color: this.color,
        ),
      ],
    );
  }
}




