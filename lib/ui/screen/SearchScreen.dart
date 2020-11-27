import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductListScreen.dart';
import 'package:got_it/ui/widget/TagChooser.dart';
import 'package:permission_handler/permission_handler.dart';

import 'ProductScreen.dart';

class SearchScreen extends StatefulWidget {
  static Future<dynamic> start(BuildContext context) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (_) => SearchScreen()));
  }

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final GlobalKey<TagSelectorState> _tagSelectorKey =
      GlobalKey(debugLabel: "tagSelectorKey");
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _textEditingController = TextEditingController();

  Repository _repository;

  @override
  void initState() {
    super.initState();
    _repository = RepositoryProvider.of(context);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  String validateInput(BuildContext context, String titleRegex) {
    if (titleRegex.isEmpty && _tagSelectorKey.currentState.tags.isEmpty) {
      return FlutterI18n.translate(context, "search.error");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          title: Text(FlutterI18n.translate(context, "search.title")),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Align(
                alignment: Alignment(-0.9, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Text(
                    FlutterI18n.translate(context, "search.by_title"),
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w700),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                      suffixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8))),
                      hintText: FlutterI18n.translate(context, "search.hint")),
                  validator: (value) => validateInput(context, value),
                ),
              ),
            ),
            Align(
                alignment: Alignment(-0.9, 0),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Text(
                    FlutterI18n.translate(context, "search.by_tags"),
                    style: TextStyle(
                        color: Colors.black54, fontWeight: FontWeight.w700),
                  ),
                )),
            Flexible(
              child: Align(
                  alignment: Alignment(-0.9, 0),
                  heightFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 2),
                    child: TagSelector({}, key: _tagSelectorKey),
                  )),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
              child: MaterialButton(
                onPressed: () {
                  FocusScopeNode focus = FocusScope.of(context);
                  if (!focus.hasPrimaryFocus) focus.unfocus();

                  if (_formKey.currentState.validate()) {
                    ProductListScreen.start(
                        context,
                        _textEditingController.text,
                        _tagSelectorKey.currentState.tags,
                        {},
                        appBarTitle: "product_list.search_title",
                        libraryView: LibraryView.Search);
                  }
                },
                child: Text(FlutterI18n.translate(context, "search.title"),
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                color: Theme.of(context).accentColor,
                minWidth: MediaQuery.of(context).size.width * 0.5,
              ),
            ),
            Text(FlutterI18n.translate(context, "search.or")),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: MaterialButton(
                onPressed: () => searchByBarcode(context),
                child: Text(FlutterI18n.translate(context, "search.by_barcode"),
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                color: Theme.of(context).accentColor,
                minWidth: MediaQuery.of(context).size.width * 0.5,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> searchByBarcode(BuildContext context) async {
    // ask for permission and return if denied
    if (!(await Permission.camera.request()).isGranted) {
      return;
    }

    ScanResult result = await BarcodeScanner.scan();

    // skip empty or error returns
    if (result.type == ResultType.Cancelled ||
        result.type == ResultType.Error ||
        result.rawContent.isEmpty) {
      return;
    }

    // TODO: Error handling

    onBarcodeDetected(context, result.rawContent);
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
}
