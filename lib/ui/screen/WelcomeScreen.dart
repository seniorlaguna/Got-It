import 'package:flutter/material.dart';
import 'package:got_it/ui/screen/MainScreen.dart';

class WelcomePage extends StatelessWidget {

  final TextStyle nameStyle = TextStyle(
    fontSize: 50,
    fontFamily: "AlexBrush"
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
              child: Image.asset("assets/regina.jpg", scale: 1.7,),
            ),

            Padding(
              padding: EdgeInsets.all(20),
              child: Text("Got it!", style: nameStyle),
            )
          ],
        ),
      ),
    );
  }

}