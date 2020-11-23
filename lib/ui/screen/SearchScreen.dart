import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductListScreen.dart';
import 'package:got_it/ui/screen/ScannerScreen.dart';
import 'package:got_it/ui/widget/TagChooser.dart';

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
    return Scaffold(
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
                  ProductListScreen.start(context, _textEditingController.text,
                      _tagSelectorKey.currentState.tags, {},
                      appBarTitle: "product_list.search_title",
                      libraryView: LibraryView.Search);
                }
              },
              child: Text("search",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              color: Theme.of(context).accentColor,
              minWidth: MediaQuery.of(context).size.width * 0.5,
            ),
          ),
          Text("or"),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: MaterialButton(
              onPressed: () => ScannerScreen.start(context),
              child: Text("search by barcode",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              color: Theme.of(context).accentColor,
              minWidth: MediaQuery.of(context).size.width * 0.5,
            ),
          )
        ],
      ),
    );
  }
}
