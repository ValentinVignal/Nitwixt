import 'package:flutter/material.dart';

class ButtonSimple extends StatelessWidget {
  final Function onTap;
  final String text;
  final Color color;
  final double fontSize;
  final IconData icon;
  final double horizontalPadding;

  ButtonSimple({
    this.onTap,
    this.text = '',
    this.icon,
    this.color = Colors.white,
    this.fontSize = 18.0,
    this.horizontalPadding = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: this.onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: this.horizontalPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          border: Border.all(
            color: this.color,
            width: 2.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (this.icon == null) ? Container() : Icon(this.icon, color: this.color,),
            SizedBox(width: (this.icon == null || this.text == null || this.text.isEmpty) ? 0.0 : 5.0),
            Text(
              this.text,
              style: TextStyle(color: this.color, fontSize: this.fontSize),
            )
          ],
        ),
      ),
    );
  }
}
