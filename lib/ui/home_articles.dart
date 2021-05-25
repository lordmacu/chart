import 'dart:async';

import 'package:flutter/services.dart';
import 'package:shiba/service/api.dart';
import 'package:shiba/service/article_bloc.dart';
import 'package:shiba/service/article_bloc_provider.dart';
import 'package:shiba/ui/article_page.dart';
import 'package:shiba/ui/flip_panel.dart';
import 'package:flutter/material.dart';



class HomeArticles extends StatelessWidget {
  String lang;
  HomeArticles(this.lang);
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    Api api = new Api();
    ArticleBloc bloc = ArticleBloc(api: api);

    bloc.getArticles(param:this.lang);

    return ArticleBlocProvider(
      bloc: bloc,
      child: HomePage(),
    );
  }
}





class HomePage extends StatelessWidget {



  @override
  Widget build(BuildContext context) {


    double height = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return SafeArea(

      child: Scaffold(
        body: FlipPanel(
          itemStream: ArticleBlocProvider.of(context).articles,
          itemBuilder: (context, article, flipBack, height) =>
              ArticlePage(article, flipBack, height,(value){

                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => HomeArticles(value)));


              }),
          getItemsCallback: ArticleBlocProvider.of(context).getArticles,
          height: height,
        ),
      ),
    );
  }
}