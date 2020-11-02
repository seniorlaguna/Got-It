import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/ui/screen/WelcomeScreen.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  runApp(
      RepositoryProvider(
        create: (context) => Repository(),
        child: MaterialApp(
          title: "Got It",
          theme: ThemeData(
            backgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              color: Colors.white,
              shadowColor: Colors.transparent,
              iconTheme: IconThemeData(
                color: Colors.black
              ),
              actionsIconTheme: IconThemeData(
                color: Colors.black
              ),
              textTheme: TextTheme(
                headline6: TextStyle(
                    fontSize: 20,
                    color: Colors.black
                )
              )
            )
          ),

          localizationsDelegates: [
            FlutterI18nDelegate(fallbackFile: "en"),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],

          home: WelcomePage(), //ExampleScreen(),
          builder: (context, child) {
            return MediaQuery(
              child: child,
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            );
          },
        ),
      )
  );
}