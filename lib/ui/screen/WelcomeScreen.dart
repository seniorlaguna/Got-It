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
          context, SlowMaterialPageRoute(page: MainScreen()));
    });

    return SafeArea(
      child: Scaffold(
          body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Hero(
            tag: "logo",
            child: Image.asset("assets/logo.jpg",
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

class SlowMaterialPageRoute extends PageRouteBuilder {
  final Widget page;

  SlowMaterialPageRoute({this.page})
      : super(
            pageBuilder: (_, __, ___) => page,
            transitionDuration: Duration(seconds: 2),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              Animation<Offset> _positionAnimation =
                  animation.drive(Tween<Offset>(
                begin: const Offset(0.0, 0.25),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.fastOutSlowIn)));
              Animation<double> _opacityAnimation =
                  animation.drive(CurveTween(curve: Curves.easeIn));

              return SlideTransition(
                position: _positionAnimation,
                child: FadeTransition(
                  opacity: _opacityAnimation,
                  child: child,
                ),
              );
            });
}
