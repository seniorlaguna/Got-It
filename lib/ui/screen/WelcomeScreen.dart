import 'package:flutter/material.dart';
import 'package:got_it/ui/screen/MainScreen.dart';

RichText titleText = RichText(
    text: TextSpan(children: [
  TextSpan(
      text: "Got It",
      style: TextStyle(
          fontFamily: "Satisfy", fontSize: 64, color: Color(0xff858585))),
  TextSpan(
      text: "!",
      style: TextStyle(
          fontFamily: "Satisfy", fontSize: 64, color: Color(0xffdc9a9b)))
]));

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 1), () async {
      Navigator.pushReplacement(
          context, SlowMaterialPageRoute(builder: (context) => MainScreen()));
    });

    /*
    Material(
              child: Text("Got It!",
                  style: TextStyle(
                      fontFamily: "Satisfy",
                      fontSize: 64,
                      color: Color(0xff858585))),
            )
    */

    return Scaffold(
        body: Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Hero(
          tag: "logo",
          child: Image.asset("assets/empty.png",
              height: MediaQuery.of(context).size.height / 3.8),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
          child: Hero(
            tag: "title",
            child: titleText,
          ),
        )
      ]),
    ));
  }
}

class SlowMaterialPageRoute extends MaterialPageRoute {
  SlowMaterialPageRoute({Function(BuildContext) builder})
      : super(builder: builder);

  @override
  Duration get transitionDuration => Duration(seconds: 2);
}
