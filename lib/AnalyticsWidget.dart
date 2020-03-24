import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class Analytics {

  final FirebaseAnalytics firebaseAnalytics;
  static Analytics _instance;

  Analytics._(this.firebaseAnalytics);

  static Analytics getInstance() {
    if (_instance == null) {
      WidgetsFlutterBinding.ensureInitialized();
      _instance = Analytics._(FirebaseAnalytics());
    }

    return _instance;
  }

}