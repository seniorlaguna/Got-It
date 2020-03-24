import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:got_it/AnalyticsWidget.dart';
import 'package:got_it/data/Repository.dart';
import 'package:got_it/ui/screen/WelcomeScreen.dart';

void main() async {
  runApp(
      RepositoryProvider(
        create: (context) => Repository(),
        child: MaterialApp(
          title: "Got It",
          theme: ThemeData.light(),

          localizationsDelegates: [
            FlutterI18nDelegate(fallbackFile: "en"),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate
          ],

          home: WelcomePage(),
        ),
      )
  );
}