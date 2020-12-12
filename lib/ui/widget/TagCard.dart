import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class TagCard extends StatelessWidget {
  final String text;
  final String imagePath;
  final Function onClick;
  final bool specialTag;
  final Color fontColor;

  TagCard(
      this.text, this.imagePath, this.onClick, this.specialTag, this.fontColor,
      {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Stack(
        children: <Widget>[
          Hero(
            tag: specialTag ? "No Hero For: $text" : text,
            child: Image.asset(
              imagePath,
              width: MediaQuery.of(context).size.width / 2,
              fit: BoxFit.cover,
            ),
          ),
          specialTag
              ? Center(
                  child: Text(
                  "${FlutterI18n.translate(context, text)}",
                  style: TextStyle(
                      color: Theme.of(context).accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                ))
              : Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    "${FlutterI18n.translate(context, text)}",
                    style: TextStyle(
                        color: fontColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w500),
                  ))
        ],
      ),
    );
  }
}
