import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path/path.dart';
import 'dart:ui' as ui;

import 'package:path_provider/path_provider.dart';

class ShareTemplate extends StatefulWidget {
  final GlobalKey _key = GlobalKey();

  Future<String> generateImage() async {
    RenderRepaintBoundary rb = _key.currentContext.findRenderObject();
    ui.Image img = await rb.toImage();
    ByteData byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    String path = join((await getTemporaryDirectory()).path, "share.png");
    File f = File(path);
    f.writeAsBytes(byteData.buffer.asUint8List());

    return path;
  }

  @override
  _ShareTemplateState createState() => _ShareTemplateState();
}

class _ShareTemplateState extends State<ShareTemplate> {
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: widget._key,
      child: SizedBox(
        width: 512,
        height: 512,
        child: Stack(
          children: [
            Image.asset("assets/default_product_image.png",
                width: 512, height: 512, fit: BoxFit.fill),
            Text("What ever!")
          ],
        ),
      ),
    );
  }
}
