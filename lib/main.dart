import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/ui/screen/WelcomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(RepositoryProvider(
    create: (context) => Repository(),
    child: MaterialApp(
      title: "Got It!",
      theme: ThemeData(
          fontFamily: "Quest",
          accentColor: Color(0xffdc9a9b),
          backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
              color: Colors.white,
              elevation: 0,
              centerTitle: true,
              shadowColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.black),
              actionsIconTheme: IconThemeData(color: Colors.black),
              textTheme: TextTheme(
                headline6: TextStyle(
                    fontSize: 20, color: Colors.black, fontFamily: "Quest"),
              ))),
      localizationsDelegates: [
        FlutterI18nDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      home: WelcomeScreen(),
      builder: (context, child) {
        return MediaQuery(
          child: child,
          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
        );
      },
    ),
  ));
}
