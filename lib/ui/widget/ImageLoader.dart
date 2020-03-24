import 'dart:io';

import 'package:flutter/material.dart';

class ImageLoader extends StatelessWidget {

  final String filePath;
  final String fallbackAsset;

  const ImageLoader(this.filePath, {Key key, this.fallbackAsset}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    if (filePath == null || filePath.isEmpty || !File(filePath).existsSync()) {
      return Image.asset(
        fallbackAsset ?? "assets/default_product.jpg",
        width: MediaQuery.of(context).size.width,
        fit: BoxFit.cover,
      );
    }

    return Image.file(
      File(filePath),
      frameBuilder: (BuildContext context, Widget child, int frame, bool sync) {
        return frame == null ? Center(child: CircularProgressIndicator()) : child;
      },
      width: MediaQuery.of(context).size.width,
      fit: BoxFit.cover,
    );
  }

}