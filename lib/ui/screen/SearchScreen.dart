import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/bloc/TagSelectorBloc.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductListScreen.dart';
import 'package:got_it/ui/widget/TagSelector.dart';
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
    TagSelectorBloc bloc = BlocProvider.of<TagSelectorBloc>(context);

    if (titleRegex.isEmpty && bloc.state.isEmpty) {
      return FlutterI18n.translate(context, "search.error");
    }
    return null;
  }

  TagSelectorBloc createBloc(BuildContext context) {
    return TagSelectorBloc(RepositoryProvider.of<Repository>(context))..add({});
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: createBloc,
      child: Builder(
        builder: (BuildContext context) {
          return SafeArea(
            child: Scaffold(
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                title: Text(FlutterI18n.translate(context, "search.title")),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                      alignment: Alignment(-0.9, 0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(
                          FlutterI18n.translate(context, "search.by_title"),
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w700),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                            hintText:
                                FlutterI18n.translate(context, "search.hint")),
                        validator: (value) => validateInput(context, value),
                      ),
                    ),
                  ),
                  Spacer(),
                  Align(
                      alignment: Alignment(-0.9, 0),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(
                          FlutterI18n.translate(context, "search.by_tags"),
                          style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.w700),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TagSelector(
                        RepositoryProvider.of<Repository>(context),
                        BlocProvider.of<TagSelectorBloc>(context),
                        searchSelector: true),
                  ),
                  Spacer(),
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        onPressed: () {
                          FocusScopeNode focus = FocusScope.of(context);
                          if (!focus.hasPrimaryFocus) focus.unfocus();

                          if (_formKey.currentState.validate()) {
                            ProductListScreen.start(
                                context,
                                _textEditingController.text,
                                BlocProvider.of<TagSelectorBloc>(context).state,
                                {},
                                appBarTitle: "product_list.search_title",
                                libraryView: LibraryView.Search);
                          }
                        },
                        child: Text(
                            FlutterI18n.translate(context, "search.title"),
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        color: Theme.of(context).accentColor,
                        minWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                    ),
                  ),
                  Align(
                      child: Text(FlutterI18n.translate(context, "search.or"))),
                  Align(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.0),
                        ),
                        onPressed: () => searchByBarcode(context),
                        child: Text(
                            FlutterI18n.translate(context, "search.by_barcode"),
                            style:
                                TextStyle(color: Colors.white, fontSize: 18)),
                        color: Theme.of(context).accentColor,
                        minWidth: MediaQuery.of(context).size.width * 0.5,
                      ),
                    ),
                  ),
                  Spacer(
                    flex: 4,
                  )
                ],
              ),
            ),
          );
        },
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
          FlutterI18n.translate(context, "dialog.title.not_found"),
          FlutterI18n.translate(context, "dialog.text.not_found"),
          FlutterI18n.translate(context, "dialog.action.ok"),
          FlutterI18n.translate(context, "dialog.action.add"),
          (context, barcode) {
        return ProductScreen.start(
            context, Product.empty().copyWith(barcode: barcode), true, true);
      });
    }

    // in trash
    else if (p.delete) {
      await _showDialog(
          context,
          barcode,
          FlutterI18n.translate(context, "dialog.title.got_it_trash"),
          FlutterI18n.translate(context, "dialog.text.got_it_trash"),
          FlutterI18n.translate(context, "dialog.action.ok"),
          FlutterI18n.translate(context, "dialog.action.show_trash"),
          (context, barcode) {
        return ProductListScreen.openTrash(context);
      });
    }

    // found
    else {
      await _showDialog(
          context,
          barcode,
          FlutterI18n.translate(context, "dialog.title.got_it"),
          FlutterI18n.translate(context, "dialog.text.got_it"),
          FlutterI18n.translate(context, "dialog.action.ok"),
          FlutterI18n.translate(context, "dialog.action.show_product"),
          (context, barcode) async {
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
