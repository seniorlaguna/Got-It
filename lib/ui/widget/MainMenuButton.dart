import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MainMenuButton extends StatelessWidget {
  final String assetPath;
  final Function onClick;
  final double size;

  const MainMenuButton(this.assetPath, this.onClick, this.size, {Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: size * 2,
          height: size * 2,
          child: Image.asset(assetPath,
              width: size, height: size, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
