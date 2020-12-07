import 'package:flutter/cupertino.dart';
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
          context, SlowMaterialPageRoute(builder: (_) => MainScreen()));
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

class SlowMaterialPageRoute extends MaterialPageRoute {
  SlowMaterialPageRoute({Function(BuildContext) builder})
      : super(builder: builder);

  static final Tween<Offset> _bottomUpTween = Tween<Offset>(
    begin: const Offset(0.0, 0.25),
    end: Offset.zero,
  );
  static final Animatable<double> _fastOutSlowInTween =
      CurveTween(curve: Curves.fastOutSlowIn);
  static final Animatable<double> _easeInTween =
      CurveTween(curve: Curves.easeIn);

  Animation<Offset> _positionAnimation;
  Animation<double> _opacityAnimation;

  @override
  Duration get transitionDuration => Duration(seconds: 2);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    _positionAnimation =
        animation.drive(_bottomUpTween.chain(_fastOutSlowInTween));
    _opacityAnimation = animation.drive(_easeInTween);

    return SlideTransition(
      position: _positionAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: child,
      ),
    );
  }
}
