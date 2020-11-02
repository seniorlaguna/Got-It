import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:got_it/bloc/LibraryBloc.dart';
import 'package:got_it/model/Product.dart';
import 'package:got_it/ui/screen/ProductListScreen.dart';
import 'package:got_it/ui/widget/TagChooser.dart';

class SearchScreen extends StatefulWidget {

  static Future<dynamic> start(BuildContext context) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen()));
  }

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _textEditingController = TextEditingController();
  Set<String> _selectedTags = {};

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  String validateInput(BuildContext context, String titleRegex) {
    if (titleRegex.isEmpty && _selectedTags.isEmpty) {
      return FlutterI18n.translate(context, "search.error");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: Text(FlutterI18n.translate(context, "search.by_title"), style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700
                ),),
              )
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: _textEditingController,
                decoration: InputDecoration(
                  suffixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8))
                  ),
                  hintText: FlutterI18n.translate(context, "search.hint")
                ),
                validator: (value) => validateInput(context, value),
              ),
            ),
          ),
          Align(
              alignment: Alignment(-0.9, 0),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                child: Text(FlutterI18n.translate(context, "search.by_tags"), style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w700
                ),),
              )
          ),
          Flexible(
            child: Wrap(
              children: [
                for (String tag in allTags) Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: SelectableTag(tag, _selectedTags.contains(tag), () {
                    if (_selectedTags.contains(tag)) {
                      setState(() {
                        _selectedTags.remove(tag);
                      });
                    }
                    else {
                      setState(() {
                        _selectedTags.add(tag);
                      });
                    }
                  }),
                )
              ],
            ),
          ),
          MaterialButton(onPressed: () {

            FocusScopeNode focus = FocusScope.of(context);
            if (!focus.hasPrimaryFocus) focus.unfocus();

            if (_formKey.currentState.validate()) {
              ProductListScreen.start(context, _textEditingController.text, _selectedTags, {}, appBarTitle: "product_list.search_title", libraryView: LibraryView.Search);
            }
          },
            child: Text("Search", style: TextStyle(color: Colors.white, fontSize: 18)),
          color: Colors.lightBlue,
          minWidth: MediaQuery.of(context).size.width * 0.95,)
        ],
      ),
    );
  }
}