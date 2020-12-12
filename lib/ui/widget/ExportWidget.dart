import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ExportWidget extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;

  const ExportWidget(this.imagePath, this.width, this.height, {Key key})
      : super(key: key);

  static TextStyle textStyle = TextStyle(fontSize: 34);

  @override
  ExportWidgetState createState() => ExportWidgetState();
}

class ExportWidgetState extends State<ExportWidget> {
  GlobalKey _exportKey = GlobalKey();
  bool _process = false;

  Future<void> exportImage(String path) async {
    try {
      setState(() {
        _process = true;
      });

      // wait a little to draw image first time
      await Future.delayed(Duration(milliseconds: 50));

      RenderRepaintBoundary renderRepaintBoundary =
          _exportKey.currentContext.findRenderObject();

      ui.Image image = await renderRepaintBoundary.toImage(pixelRatio: 2);
      File out = File(path);
      out.writeAsBytesSync(
          (await image.toByteData(format: ui.ImageByteFormat.png))
              .buffer
              .asInt8List());

      setState(() {
        _process = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool imageExists = widget.imagePath != null &&
        widget.imagePath.isNotEmpty &&
        File(widget.imagePath).existsSync();

    return Offstage(
      offstage: !_process,
      child: RepaintBoundary(
        key: _exportKey,
        child: Stack(
          children: [
            imageExists
                ? Image.file(File(widget.imagePath),
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.cover)
                : Image.asset("assets/default_product_image.jpg",
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.cover),
            Image.asset("assets/share_image_overlay.png",
                width: widget.width, height: widget.height, fit: BoxFit.fill)
          ],
        ),
      ),
    );
  }
}
