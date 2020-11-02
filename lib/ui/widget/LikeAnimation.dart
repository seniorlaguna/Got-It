import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LikeAnimation extends StatelessWidget {

  static final Tween<double> _tween = Tween(begin: 0, end: 1);

  final AnimationController _animationController;
  const LikeAnimation(this._animationController, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    print("Opacity: ${1 - sin(_animationController.value)}");

    return AnimatedBuilder(
        animation: _tween.animate(_animationController),
        child: Icon(Icons.favorite, size: 48, color: Colors.white),
        builder: (context, child) {
          return Opacity(
              opacity: 1 - pow(_animationController.value, 4),
              child: Transform.scale(
                  scale: _animationController.value * 3,
                  child: child,
              ),
          );
        }
    );
  }
}