import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductScreen.dart';
import 'package:got_it/ui/screen/SearchScreen.dart';
import 'package:got_it/ui/screen/TagsScreen.dart';
import 'package:got_it/ui/screen/WelcomeScreen.dart';
import 'package:got_it/ui/widget/BarcodeScannerDialog.dart';
import 'package:got_it/ui/widget/MainMenuButton.dart';

import 'InfoScreen.dart';

void showGifDialog(
    BuildContext context, String gifPath, String title, String text) {
  showDialog(
      context: context,
      builder: (_) => AssetGiffyDialog(
          image: Image.asset(gifPath, fit: BoxFit.cover),
          title: Text(
            FlutterI18n.translate(context, title),
            style: TextStyle(fontSize: 32.0, fontWeight: FontWeight.w600),
          ),
          description: Text(
            FlutterI18n.translate(context, text),
            textAlign: TextAlign.center,
          ),
          entryAnimation: EntryAnimation.TOP,
          onlyOkButton: true,
          buttonOkColor: Colors.lightGreen,
          onOkButtonPressed: () => Navigator.pop(context)));
}

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.black),
              itemBuilder: (context) {
                return ["Credits", "AGBs", "Datenschutz", "Impressum"]
                    .map((e) => PopupMenuItem(child: Text(e), value: e))
                    .toList();
              },
              onSelected: (i) {
                switch (i) {
                  case "Credits":
                    showAboutDialog(
                        context: context,
                        applicationName: "Got It",
                        applicationVersion: "Version 1.0",
                        applicationLegalese: "Mady by Regina Fiedler");
                    break;
                  default:
                    InfoScreen.start(context, i, "Text");
                }
              },
            ),
          ],
        ),
        body: Builder(builder: (context) => _getBody(context)));
  }

  Widget _getBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Hero(
              tag: "logo",
              child: Image.asset("assets/empty.png",
                  height: MediaQuery.of(context).size.height / 8),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
              child: Hero(
                tag: "title",
                child: titleText,
              ),
            )
          ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MainMenuButton(
                "assets/button_search.png", () => onClickSearch(context), 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 78.0),
              child: MainMenuButton("assets/button_collection.png",
                  () => onClickLibrary(context), 46),
            ),
            MainMenuButton(
                "assets/button_add.png", () => onClickAdd(context), 32)
          ],
        ),
      ],
    );
  }

  void onClickLibrary(BuildContext context) {
    TagsScreen.start(context);
  }

  void onClickSearch(BuildContext context) {
    SearchScreen.start(context);
  }

  void onBarcodeDetected(BuildContext context, String barcode) async {
    String dialogGif;
    String dialogTitle;
    String dialogText;

    try {
      Repository repository = RepositoryProvider.of<Repository>(context);

      // on back pressed
      if (barcode.isEmpty) return;

      Product product = await repository.getProductByBarcode(barcode);

      // found
      if (product != null) {
        dialogGif = "assets/dialog/found.gif";
        dialogTitle = FlutterI18n.translate(context, "dialog.title.got_it");
        dialogText = FlutterI18n.translate(context, "dialog.text.got_it");
      } else {
        dialogGif = "assets/dialog/not_found.gif";
        dialogTitle = FlutterI18n.translate(context, "dialog.title.not_found");
        dialogText = FlutterI18n.translate(context, "dialog.text.not_found");
      }
    } catch (_) {
      dialogGif = "assets/dialog/error.gif";
      dialogTitle = FlutterI18n.translate(context, "dialog.title.error");
      dialogText = FlutterI18n.translate(context, "dialog.text.error");
    }

    showGifDialog(context, dialogGif, dialogTitle, dialogText);
  }

  void onClickAdd(BuildContext context) async {
    ProductScreen.start(context, Product.empty(), true, true);
  }
}
