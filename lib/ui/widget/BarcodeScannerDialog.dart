import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:last_qr_scanner/last_qr_scanner.dart';

/*
  That's the barcode scanner used on ProductScreen
 */

class EmbeddedBarcodeScannerDialog extends StatefulWidget {
  final double _width;
  final double _height;
  final double _appBarHeight;
  final Function(String) _onBarcodeDetected;

  const EmbeddedBarcodeScannerDialog(
      this._width, this._height, this._appBarHeight, this._onBarcodeDetected,
      {Key key})
      : super(key: key);

  @override
  _EmbeddedBarcodeScannerDialogState createState() =>
      _EmbeddedBarcodeScannerDialogState();
}

class _EmbeddedBarcodeScannerDialogState
    extends State<EmbeddedBarcodeScannerDialog> {
  QRViewController _qrViewController;

  void onCancel(BuildContext context) async {
    Navigator.pop(context);
  }

  void onQRViewCreated(
      BuildContext context, QRViewController qrViewController) {
    _qrViewController = qrViewController;

    _qrViewController.channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onRecognizeQR":
          dynamic arguments = call.arguments;
          print("[BarcodeScannerDialog] Barcode: <<${arguments.toString()}>>");
          widget._onBarcodeDetected(arguments.toString());
          _qrViewController.pauseScanner();
          Navigator.pop(context);
      }

      return;
    });
  }

  Widget getCameraPreview(BuildContext context) {
    return Stack(children: [
      LastQrScannerPreview(
          onQRViewCreated: (QRViewController controller) =>
              onQRViewCreated(context, controller)),
      Positioned(
          bottom: 8,
          left: 8,
          child: GestureDetector(
              child: Icon(
                Icons.cancel_outlined,
                size: 40,
                color: Colors.white,
              ),
              onTap: () => onCancel(context))),
      Align(
        alignment: Alignment(0, -0.9),
        child: Material(
          child: Text(FlutterI18n.translate(context, "product.scan_barcode"),
              style: TextStyle(
                  fontFamily: "Quest",
                  backgroundColor: Colors.black54,
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.none)),
        ),
      ),
    ]);
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
              child: getCameraPreview(context),
            ))
      ],
    );
  }
}

/*
  That's the barcode scanner used on MainScreen
 */

class PopupBarcodeScannerDialog extends StatefulWidget {
  final Function(String) _onBarcodeDetected;

  const PopupBarcodeScannerDialog(this._onBarcodeDetected, {Key key})
      : super(key: key);

  @override
  _PopupBarcodeScannerDialogState createState() =>
      _PopupBarcodeScannerDialogState();
}

class _PopupBarcodeScannerDialogState extends State<PopupBarcodeScannerDialog> {
  QRViewController _qrViewController;

  void _onQRViewCreated(
      BuildContext context, QRViewController qrViewController) {
    _qrViewController = qrViewController;
    _qrViewController.channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onRecognizeQR":
          dynamic arguments = call.arguments;
          print(
              "[PopupBarcodeScannerDialog] Barcode: <<${arguments.toString()}>>");
          widget._onBarcodeDetected(arguments.toString());
          _qrViewController.pauseScanner();
          Navigator.pop(context);
      }

      return;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width * 0.75;

    return Stack(children: [
      Align(
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(8)),
        ),
      ),
      Align(
        child: SizedBox(
          width: width,
          height: width,
          child: LastQrScannerPreview(
              onQRViewCreated: (controller) =>
                  _onQRViewCreated(context, controller)),
        ),
      ),
      Align(
        alignment: Alignment(0, -0.35),
        child: Material(
          child: Text(FlutterI18n.translate(context, "product.scan_barcode"),
              style: TextStyle(
                  fontFamily: "Quest",
                  backgroundColor: Colors.black54,
                  color: Colors.white,
                  fontSize: 16,
                  decoration: TextDecoration.none)),
        ),
      )
    ]);
  }
}
