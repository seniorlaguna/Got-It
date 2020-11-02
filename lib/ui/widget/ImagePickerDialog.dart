import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerDialog extends StatefulWidget {

  final CameraDescription _cameraDescription;
  final String _tmpDirPath;
  final String _targetPath;
  final double _width;
  final double _height;
  final double _appBarHeight;
  final Function _onImageSaved;

  const ImagePickerDialog(this._cameraDescription, this._tmpDirPath, this._targetPath, this._width, this._height, this._appBarHeight, this._onImageSaved, {Key key}) : super(key: key);

  @override
  _ImagePickerDialogState createState() => _ImagePickerDialogState();
}

class _ImagePickerDialogState extends State<ImagePickerDialog> {

  CameraController _cameraController;
  Future<void> _initializeControllerFuture;
  bool imageTaken = false;
  String imagePath = "";
  
  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
        widget._cameraDescription,
        ResolutionPreset.medium,
        enableAudio: false
    );

    _initializeControllerFuture = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void onTakeImage() async {
    // delete temp file if exists
    String tempFilePath = join(widget._tmpDirPath, "${DateTime.now()}.jpg");
    File tempFile = File(tempFilePath);
    if (tempFile.existsSync()) {
      tempFile.deleteSync();
    }

    // wait for camera and then take picture
    await _initializeControllerFuture;
    await _cameraController.takePicture(tempFilePath);

    setState(() {
      imageTaken = true;
      imagePath = tempFilePath;
    });
  }

  void onSaveImage(BuildContext context) async {
    File(imagePath).renameSync(widget._targetPath);

    // callback
    widget._onImageSaved();

    // close dialog
    Navigator.pop(context);
  }

  void onCancel() async {
    File(imagePath).delete();

    setState(() {
      imageTaken = false;
    });
  }

  Widget getCameraPreview(BuildContext context) {

    return FutureBuilder(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
                children: [
                  CameraPreview(_cameraController),
                  Align(
                      alignment: Alignment(0, 0.9),
                      child: GestureDetector(child: Icon(Icons.camera_alt_outlined, size: 40, color: Colors.white,), onTap: onTakeImage)
                  ),
                  Align(
                    alignment: Alignment(0, -0.9),
                    child: Text(FlutterI18n.translate(context, "product.take_picture"), style: TextStyle(
                        backgroundColor: Colors.black54,
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.none
                    )),
                  )
                ]
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );

        }
    );

  }

  Widget getImagePreview(BuildContext context) {

    return Stack(
        children: [
          Image.file(File(imagePath), width: widget._width, height: widget._height, fit: BoxFit.fill),
          Positioned(
              bottom: 8,
              left: 8,
              child: GestureDetector(child: Icon(Icons.cancel_outlined, size: 40, color: Colors.white), onTap: onCancel)
          ),
          Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(child: Icon(Icons.done, size: 40, color: Colors.white), onTap: () => onSaveImage(context))
          ),
        ]
    );
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Positioned(
            top: widget._appBarHeight,
            child: SizedBox(
              width: widget._width,
              height: widget._height,
              child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: imageTaken ? getImagePreview(context) : getCameraPreview(context)
              ),
            )
        )
      ],
    );
  }
}