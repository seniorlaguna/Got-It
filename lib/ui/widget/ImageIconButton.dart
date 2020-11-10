import 'package:flutter/material.dart';

class ImageIconButton extends StatelessWidget {

  final String assetPath;
  final Function onTap;

  ImageIconButton(this.assetPath, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Image.asset(
            assetPath,
            width: 28,
            height: 28,
        ),
      ),
    );
  }



}