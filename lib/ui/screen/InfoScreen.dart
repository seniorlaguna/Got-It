import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class InfoScreen extends StatelessWidget {
  final String _title;
  final String _text;

  static final TextStyle _titleTextStyle = TextStyle(fontSize: 26);

  static final TextStyle _textTextStyle = TextStyle(fontSize: 16);

  static Future<void> start(BuildContext context, String title, String text) {
    return Navigator.push(
        context, MaterialPageRoute(builder: (_) => InfoScreen(title, text)));
  }

  const InfoScreen(this._title, this._text, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  FlutterI18n.translate(context, _title),
                  style: _titleTextStyle,
                ),
              ),
            ),
            Text(FlutterI18n.translate(context, _text), style: _textTextStyle)
          ],
        ),
      ),
    );
  }
}
