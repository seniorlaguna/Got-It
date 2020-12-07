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

    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Hero(
                tag: "logo",
                child: Image.asset("assets/logo.png",
                    height: MediaQuery.of(context).size.height / 2.8),
              ),
              Hero(
                tag: "title",
                child: titleText,
              )
            ]),
          )),
    );
  }
}

class SlowMaterialPageRoute<T> extends MaterialPageRoute<T> {
  SlowMaterialPageRoute({Function(BuildContext) builder})
      : super(builder: builder);

  @override
  Duration get transitionDuration => Duration(seconds: 2);
}
