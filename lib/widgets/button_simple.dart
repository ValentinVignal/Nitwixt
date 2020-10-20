import 'package:flutter/material.dart';

class ButtonSimple extends StatelessWidget {
  const ButtonSimple({
    this.onTap,
    this.text = '',
    this.icon,
    this.color = Colors.white,
    this.fontSize = 18.0,
    this.horizontalPadding = 10.0,
    this.withBorder = true,
    this.backgroundColor = const Color(0x00000000),
  });

  final void Function() onTap;
  final String text;
  final Color color;
  final double fontSize;
  final IconData icon;
  final double horizontalPadding;
  final bool withBorder;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: horizontalPadding,
        ),
        decoration: withBorder
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: color,
                  width: 2.0,
                ),
                color: backgroundColor,
              )
            : null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon == null)
              Container()
            else
              Icon(
                icon,
                color: color,
              ),
            SizedBox(width: (icon == null || text == null || text.isEmpty) ? 0.0 : 5.0),
            Text(
              text,
              style: TextStyle(color: color, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}
