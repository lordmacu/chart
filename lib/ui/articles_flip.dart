import 'dart:io';
import 'package:shiba/model/article.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:shiba/service/api.dart';
import 'package:shiba/service/article_bloc.dart';
import 'package:shiba/service/article_bloc_provider.dart';
import 'package:shiba/ui/article_page.dart';
import 'package:shiba/ui/flip_panel.dart';

class ArticleFlip extends StatefulWidget {

  @override
  ArticleFlipState createState() => ArticleFlipState();
}

class ArticleFlipState extends State<ArticleFlip> {
  ArticleBloc bloc;
  Api api;

  @override
  void initState() {
    super.initState();
    api = new Api();
    bloc = ArticleBloc(api: api);
    bloc.getArticles(param: "all");

  }

  @override
  Widget build(BuildContext context) {

    // Calculate height of the page before applying the SafeArea since it removes
    // the padding from the MediaQuery and can not calculate it inside the page.
    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return SafeArea(
      // This Scaffold is used to display the FlipPane SnackBar. Later,
      // each article page will have its own Scaffold
      child: Scaffold(
        body: bloc!=null ? ArticleBlocProvider(
          bloc: bloc,
          child:FlipPanel(
            itemStream: ArticleBlocProvider.of(context).articles,
            itemBuilder: (context, article, flipBack, height) =>
                ArticlePage(article, flipBack, height,(value){
                  print("este es el valor ${value}");

                  bloc.getArticles(param: value);

                }),
            getItemsCallback: ArticleBlocProvider.of(context).getArticles,
            height: height,
          ) ,
        ) : Container(),
      ),
    );
  }
}