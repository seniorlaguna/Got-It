import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SVGIconButton extends StatelessWidget {

  final String assetPath;
  final Function onTap;

  SVGIconButton(this.assetPath, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: SvgPicture.asset(
            assetPath,
            width: 28,
            height: 28,
        ),
      ),
    );
  }



}