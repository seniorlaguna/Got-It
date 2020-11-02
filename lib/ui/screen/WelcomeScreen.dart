import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/ui/screen/MainScreen.dart';

class WelcomePage extends StatelessWidget {

  final TextStyle nameStyle = TextStyle(
    fontSize: 50,
    fontFamily: "IndieFlower"
  );

  final int duration = 3;

  @override
  Widget build(BuildContext context) {

    Future.delayed(Duration(seconds: duration), () async {
      Navigator.pushReplacement(context, MaterialPageRoute(
          builder: (context) => MainPage()
      ));
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipOval(
              child: Image.asset("assets/goat.png", scale: 2,),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Text(FlutterI18n.translate(context, "title"), style: nameStyle),
            )
          ],
        ),
      ),
    );
  }

}