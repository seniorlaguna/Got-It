import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {

  final Function onClick;
  final IconData iconData;
  final String text;
  final double textSize;
  final double textPadding;
  final Color textColor;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;

  MyIconButton(this.onClick, this.iconData, this.text, {this.textSize = 16, this.textPadding = 4, this.textColor = Colors.black54, this.iconSize = 28, this.iconColor = Colors.pink, this.backgroundColor = Colors.transparent, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Center(
        child: Container(
          color: backgroundColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  iconData,
                  color: iconColor,
                  size: iconSize,
                ),

                Padding(
                  padding: EdgeInsets.all(textPadding),
                  child: Text(text, style: TextStyle(fontSize: textSize, color: textColor, fontWeight: FontWeight.w400),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}