import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/AnalyticsWidget.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/CategoriesScreen.dart';
import 'package:got_it/ui/screen/ProductEditor.dart';
import 'package:got_it/ui/screen/WishListViewer.dart';
import 'package:got_it/ui/widget/MyIconButton.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'ProductEditor.dart';

class MainPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        body: Builder(builder: (context) => _getBody(context))
    );
  }

  Widget _getAppBar(BuildContext context) {
    return Stack(
      children: <Widget> [
        Image.asset("assets/homepage.jpg", fit: BoxFit.fitHeight, height: MediaQuery.of(context).size.height / 2,),

        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        )
      ]
    );
  }

  Widget _getBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Flexible(
            fit: FlexFit.tight,
            flex: 1,
            child: _getAppBar(context)
        ),

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
                        MyIconButton(() => onClickLibrary(context), Icons.view_module, FlutterI18n.translate(context, "main_screen.library")),
                        MyIconButton(() => onClickWishList(context), Icons.stars, FlutterI18n.translate(context, "main_screen.wishlist"))
                      ],
                    )
                ),

                Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        MyIconButton(() => onClickSearch(context), Icons.search, FlutterI18n.translate(context, "main_screen.got_it")),
                        MyIconButton(() => onClickAdd(context), Icons.add, FlutterI18n.translate(context, "main_screen.add"))
                      ],
                    )
                )
              ],
            )
        )
      ],
    );
  }

  void onClickLibrary(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (BuildContext context) => CategoriesScreen()
    ));
  }

  void onClickSearch(BuildContext context) async {
    Analytics.getInstance().firebaseAnalytics.logEvent(name: "scan_barcode_mainscreen");

    String barcode;
    try {
      barcode = await BarcodeScanner.scan();
    } catch (_) {
      return;
    }

    Repository repository =  RepositoryProvider.of<Repository>(context);

    if (barcode == null || barcode.isEmpty) {
      Alert(
        context: context,
        title: FlutterI18n.translate(context, "alerts.error"),
        desc: FlutterI18n.translate(context, "alerts.could_not_read"),
        type: AlertType.warning,
      ).show();
    }

    else if (await repository.inLibrary(barcode)) {
      Alert(
        context: context,
        title: FlutterI18n.translate(context, "alerts.got_it"),
        desc: FlutterI18n.translate(context, "alerts.already_in_library"),
        type: AlertType.success,
      ).show();
    }

    else if (await repository.inWishList(barcode)) {
      Alert(
        context: context,
        title: FlutterI18n.translate(context, "alerts.already_in_wishlist"),
        type: AlertType.info,
      ).show();
    }

    else {
      Alert(
          context: context,
          title: FlutterI18n.translate(context, "alerts.not_yet"),
          desc: FlutterI18n.translate(context, "alerts.not_in_library"),
          type: AlertType.error,
          buttons: <DialogButton>[
            DialogButton(
                child: Center(child: Text(FlutterI18n.translate(context, "alerts.put_on_wishlist"), textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),)),
                onPressed: () async {
                  await ProductEditor.start(context, Product.empty().copyWith(barcode: barcode, wish: true));
                  Navigator.of(context).pop();
                }
            ),

            DialogButton(
                child: Center(child: Text(FlutterI18n.translate(context, "alerts.okay"), style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),)),
                onPressed: () => Navigator.of(context).pop()
            )
          ]
      ).show();
    }
  }

  void onClickWishList(BuildContext context) {
    WishListViewer.start(context);
  }

  void onClickAdd(BuildContext context) {
    ProductEditor.start(context, Product.empty());
  }


}