import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class InfoScreen extends StatelessWidget {
  final String _key;

  static final TextStyle _titleTextStyle = TextStyle(fontSize: 26);

  static final TextStyle _headerTextStyle =
      TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
  static final TextStyle _textTextStyle = TextStyle(fontSize: 16);

  static Future<void> start(BuildContext context, String key) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (_) => InfoScreen(key)));
  }

  const InfoScreen(this._key, {Key key}) : super(key: key);

  Widget getText(BuildContext context) {
    List<Widget> children = [];
    int i = 1;

    if (_key == "datenschutz") {
      children.add(Text(
        FlutterI18n.translate(context, "datenschutz.prolog"),
        style: _textTextStyle,
      ));
    }

    while (
        FlutterI18n.translate(context, "$_key.header$i") != "$_key.header$i") {
      children.add(Text(
        FlutterI18n.translate(context, "$_key.header$i"),
        style: _headerTextStyle,
      ));
      children.add(Text(FlutterI18n.translate(context, "$_key.text$i"),
          style: _textTextStyle));
      i++;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: children,
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar:
            AppBar(title: Text(FlutterI18n.translate(context, "$_key.title"))),
        body: SingleChildScrollView(
          child: (_key == "impressum")
              ? Center(
                  child: Text(
                    FlutterI18n.translate(context, "impressum.text"),
                    style: _textTextStyle,
                  ),
                )
              : getText(context),
        ),
      ),
    );
  }
}
