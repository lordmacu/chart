import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shiba/push_notifications.dart';
import 'package:shiba/ui/home_articles.dart';
import 'package:shiba/ui/stats.dart';
import 'package:flutter/services.dart';
import 'package:shiba/service/api.dart';
import 'package:shiba/service/article_bloc.dart';
import 'package:shiba/service/article_bloc_provider.dart';
import 'package:shiba/ui/article_page.dart';
import 'package:shiba/ui/flip_panel.dart';
import 'package:flutter/material.dart';

Future main() async {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    final pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();

    Api api = new Api();
    ArticleBloc bloc = ArticleBloc(api: api);

    bloc.getArticles(param: "all");

    return MaterialApp(
      title: 'FlutBoard',
      theme: _buildTheme(),
      debugShowCheckedModeBanner: false,

      home: Stats(),
    );
  }
}



ThemeData _buildTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    accentColor: Colors.black87,
    primaryColor: Colors.white,
    scaffoldBackgroundColor: Colors.white,
    primaryIconTheme: base.iconTheme.copyWith(color: Colors.black87),
    iconTheme: base.iconTheme.copyWith(color: Colors.black87),
    textTheme: _buildShrineTextTheme(base.textTheme),
    primaryTextTheme: _buildShrineTextTheme(base.primaryTextTheme),
    accentTextTheme: _buildShrineTextTheme(base.accentTextTheme),
  );
}

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base.apply(
    displayColor: Colors.black87,
    bodyColor: Colors.black87,
  );
}
