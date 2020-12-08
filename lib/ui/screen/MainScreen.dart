import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductScreen.dart';
import 'package:got_it/ui/screen/SearchScreen.dart';
import 'package:got_it/ui/screen/TagsScreen.dart';
import 'package:got_it/ui/screen/WelcomeScreen.dart';
import 'package:got_it/ui/widget/MainMenuButton.dart';

import 'InfoScreen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.black),
                itemBuilder: (context) {
                  return [
                    "legal.credits",
                    "legal.agb",
                    "legal.datenschutz",
                    "legal.impressum"
                  ]
                      .map((e) => PopupMenuItem(
                          child:
                              Text(FlutterI18n.translate(context, "$e.title")),
                          value: e))
                      .toList();
                },
                onSelected: (i) {
                  switch (i) {
                    case "legal.credits":
                      showAboutDialog(
                        context: context,
                        applicationName: "Got It",
                        applicationVersion: FlutterI18n.translate(
                            context, "legal.credits.version"),
                        applicationLegalese: FlutterI18n.translate(
                            context, "legal.credits.others"),
                      );
                      break;
                    default:
                      InfoScreen.start(context, "$i.title", "$i.text");
                  }
                },
              ),
            ],
          ),
          body: Builder(builder: (context) => _getBody(context))),
    );
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
              child: Image.asset("assets/logo.jpg",
                  height: MediaQuery.of(context).size.height / 4),
            ),
            Hero(
              tag: "title",
              child: titleText,
            )
          ]),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MainMenuButton("assets/main/button_search.jpg",
                () => onClickSearch(context), 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 78.0),
              child: MainMenuButton("assets/main/button_collection.jpg",
                  () => onClickLibrary(context), 46),
            ),
            MainMenuButton(
                "assets/main/button_add.jpg", () => onClickAdd(context), 32)
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

  void onClickAdd(BuildContext context) async {
    ProductScreen.start(context, Product.empty(), true, true);
  }
}
