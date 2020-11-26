import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductListScreen.dart';
import 'package:got_it/ui/screen/ProductScreen.dart';
import 'package:last_qr_scanner/last_qr_scanner.dart';

class ScannerScreen extends StatefulWidget {
  static Future<dynamic> start(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) {
      return ScannerScreen();
    }));
  }

  @override
  _ScannerScreenState createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  QRViewController _qrViewController;
  Repository _repository;

  @override
  void initState() {
    super.initState();
    _repository = RepositoryProvider.of(context);
  }

  void _onQRViewCreated(
      BuildContext context, QRViewController qrViewController) {
    _qrViewController = qrViewController;

    _qrViewController.channel.setMethodCallHandler((call) {
      switch (call.method) {
        case "onRecognizeQR":
          _qrViewController.pauseScanner();
          dynamic arguments = call.arguments;
          onBarcodeDetected(context, arguments.toString());
      }
      return;
    });
  }

  void onBarcodeDetected(BuildContext context, String barcode) async {
    print("Found $barcode");
    Product p = await _repository.getProductByBarcode(barcode);

    // product not in collection
    if (p == null) {
      await _showDialog(
          context,
          barcode,
          "Sorry",
          "the product is not in your collection yet",
          "ok",
          "add product", (context, barcode) {
        return ProductScreen.start(
            context, Product.empty().copyWith(barcode: barcode), true, true);
      });
    }

    // in trash
    else if (p.delete) {
      await _showDialog(
          context,
          barcode,
          "Got It, but...",
          "the product is in your trash!",
          "ok",
          "show trash", (context, barcode) {
        return ProductListScreen.openTrash(context);
      });
    }

    // found
    else {
      await _showDialog(
          context,
          barcode,
          "Got It!",
          "the product is in your collection",
          "ok",
          "show product", (context, barcode) async {
        return ProductScreen.start(context, p, false, true);
      });
    }

    _qrViewController.resumeScanner();
  }

  Future<dynamic> _showDialog(
      BuildContext context,
      String barcode,
      String title,
      String text,
      String cancelButtonText,
      String actionButtonText,
      Function(BuildContext, String) actionButtonCallback) {
    final TextStyle buttonTextStyle =
        TextStyle(color: Theme.of(context).accentColor);

    return showDialog(
        context: context,
        child: AlertDialog(
          title: Text(FlutterI18n.translate(context, title)),
          content: Text(FlutterI18n.translate(context, text)),
          actions: [
            FlatButton(
                onPressed: () async {
                  await actionButtonCallback(context, barcode);
                  Navigator.pop(context);
                },
                child: Text(FlutterI18n.translate(context, actionButtonText),
                    style: buttonTextStyle)),
            FlatButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(FlutterI18n.translate(context, cancelButtonText),
                    style: buttonTextStyle))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final double pad = MediaQuery.of(context).size.height / 10;

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: Text(FlutterI18n.translate(context, "scan_barcode.title")),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: pad),
          child: SizedBox(
            height: width,
            width: width,
            child: LastQrScannerPreview(
              onQRViewCreated: (controller) =>
                  _onQRViewCreated(context, controller),
            ),
          ),
        ),
      ),
    );
  }
}
