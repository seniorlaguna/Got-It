import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductScreen.dart';
import 'package:got_it/ui/screen/TagsScreen.dart';
import 'package:got_it/ui/widget/MyIconButton.dart';

void showGifDialog(BuildContext context, String gifPath, String title, String text) {
  showDialog(
      context: context,
      builder: (_) => AssetGiffyDialog(
        image: Image.asset(gifPath),
        title: Text(
          FlutterI18n.translate(context, title),
          style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
        ),
        description: Text(FlutterI18n.translate(context, text)),
        entryAnimation: EntryAnimation.TOP,
        onlyOkButton: true,
        buttonOkColor: Colors.lightGreen,
        onOkButtonPressed: () => Navigator.pop(context)
      )
  );
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Builder(builder: (context) => _getBody(context)));
  }

  Widget _getAppBar(BuildContext context) {
    return Stack(children: <Widget>[
      Image.asset(
        "assets/homepage.jpg",
        fit: BoxFit.fitHeight,
        height: MediaQuery.of(context).size.height / 2,
      ),
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton(
              icon: Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (context) {
                return [
                  PopupMenuItem(child: Text("Credits"), value: 1)
                ];
              },
            onSelected: (i) => showAboutDialog(
                context: context,
                applicationName: "Got It",
                applicationVersion: "Version 1.0",
                applicationLegalese: "Producer: Regina Fiedler"
            ),
          ),
        ],
      )
    ]);
  }

  Widget _getBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(fit: FlexFit.tight, flex: 1, child: _getAppBar(context)),
        Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                    fit: FlexFit.tight,
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MyIconButton(
                            () => onClickLibrary(context),
                            Icons.view_module,
                            FlutterI18n.translate(
                                context, "main_screen.my_cosmetics")),
                      ],
                    )),
                Flexible(
                    child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    MyIconButton(() => onClickSearch(context), Icons.search,
                        FlutterI18n.translate(context, "main_screen.got_it")),
                    MyIconButton(() => onClickAdd(context), Icons.add,
                        FlutterI18n.translate(context, "main_screen.add_new"))
                  ],
                ))
              ],
            ))
      ],
    );
  }

  void onClickLibrary(BuildContext context) {
    TagsScreen.start(context);
  }

  void onClickSearch(BuildContext context) async {

    String barcode;
    String dialogGif;
    String dialogTitle;
    String dialogText;

    try {
      barcode = (await BarcodeScanner.scan()).rawContent;
      Repository repository = RepositoryProvider.of<Repository>(context);

      print("[MainScreen]  Barcode: <<$barcode>>");
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
