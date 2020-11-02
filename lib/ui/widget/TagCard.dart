import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class TagCard extends StatelessWidget {

  final String text;
  final String imagePath;
  final Function onClick;
  final bool specialTag;

  TagCard(this.text, this.imagePath, this.onClick, this.specialTag, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: GestureDetector(
          onTap: onClick,
          child: Stack(
            children: <Widget>[
              Hero(
                tag: text,
                child: Image.asset(
                  imagePath,
                  width: MediaQuery.of(context).size.width / 2,
                  height: MediaQuery.of(context).size.height / 3,
                  fit: BoxFit.cover,
                  ),
              ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  gradient: LinearGradient(
                    begin: FractionalOffset.topCenter,
                    end: FractionalOffset.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0),
                      Colors.black.withOpacity(0.6)
                    ]
                  )
                ),
              ),

              specialTag ? Center(
                  child: Text(
                    "${FlutterI18n.translate(context, text)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500
                    ),
                  )
              ) : Positioned(
                  bottom: 10,
                  left: 10,
                  child: Text(
                    "#${FlutterI18n.translate(context, text)}",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w500
                    ),
                  )
              )
            ],
          ),
        ),
      ),
    );
  }
}