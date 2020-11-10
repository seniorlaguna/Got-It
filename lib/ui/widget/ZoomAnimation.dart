import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ZoomAnimation extends StatelessWidget {

  static final Tween<double> _tween = Tween(begin: 0, end: 1);

  final AnimationController _animationController;
  final Widget _child;
  const ZoomAnimation(this._animationController, this._child, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return AnimatedBuilder(
        animation: _tween.animate(_animationController),
        child: _child,
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