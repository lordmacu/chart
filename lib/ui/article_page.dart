import 'dart:async';

import 'package:shiba/ui/home_articles.dart';
import 'package:shiba/ui/stats.dart';
import 'package:shiba/ui/web_view.dart';
import 'package:flutter/material.dart';
import 'package:shiba/model/article.dart';
import 'package:shiba/service/article_bloc_provider.dart';
import 'package:shiba/ui/about_page.dart';
import 'package:shiba/ui/sources_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart';

typedef void FlipBack({bool backToTop});

class ArticlePage extends StatefulWidget {
  final Article article;

  final FlipBack flipBack;

  final double height;
  Function loadLanguage;

  ArticlePage(this.article, this.flipBack, this.height,this.loadLanguage);

  @override
  ArticlePageState createState() {
    return new ArticlePageState();
  }
}

class ArticlePageState extends State<ArticlePage> {
  Future<Null> _selectSources(BuildContext context) async {
    String result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SourcesPage(ArticleBlocProvider.of(context))),
    );
    if (result == null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomeArticles("all")));
    }
  }

  Future<Null> _aboutPage(BuildContext context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => AboutPage()));
  }

  String _parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body.text).documentElement.text;

    return parsedString;
  }

  _launchURL() async {
    String url = widget.article.url;
    if (await canLaunch(url)) {
    //  await launch(url);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WebViewPage(widget.article)),
      );
    } else {
      Scaffold.of(context)
          .showSnackBar(SnackBar(content: Text("Could not launch $url")));
    }
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    Icon _getMenuIcon(TargetPlatform platform) {
      assert(platform != null);
      switch (platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          return const Icon(Icons.more_horiz);
        default:
          return const Icon(Icons.more_vert);
      }
    }

    Icon _getBackIcon(TargetPlatform platform) {
      assert(platform != null);
      switch (platform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          return const Icon(Icons.arrow_back_ios);
        default:
          return const Icon(Icons.arrow_back);
      }
    }

    return Container(
      color: Colors.white,
      height: widget.height,
      width: MediaQuery.of(context).size.width,
      child: WillPopScope(
        onWillPop: () {
          return new Future(() {
            if (widget.flipBack == null) return true;
            widget.flipBack();
            return false;
          });
        },
        child: Scaffold(
          appBar: AppBar(
            leading: widget.flipBack != null
                ? new IconButton(
                    icon: _getBackIcon(Theme.of(context).platform),
                    color: Colors.black87,
                    onPressed: widget.flipBack,
                  )
                : GestureDetector(
              onTap: (){
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => Stats()));
              },
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/images/shib_logo_header.png',
                ),
              ),
            ),
            title: Text(
              widget.article.source,
              style: TextStyle(color: Colors.black87),
            ),
            elevation: 0.0,
            centerTitle: true,
            actions: <Widget>[
              widget.flipBack == null
                  ? IconButton(
                      icon: new Icon(Icons.refresh),
                      //color: Colors.black87,
                      onPressed: ()  {
                      Navigator.push(
                      context, MaterialPageRoute(builder: (context) => HomeArticles("all")));
                      },
                    )
                  : Container(),
              PopupMenuButton<String>(
                itemBuilder: (BuildContext context) {
                  return <PopupMenuEntry<String>>[
                    widget.flipBack == null
                        ? PopupMenuItem<String>(
                            value: 'home',
                            child: Text('Inicio'),
                          )
                        : PopupMenuItem<String>(
                            value: 'back',
                            child: Text('Ir al Home'),
                          ),
                    PopupMenuItem<String>(
                      value: 'spanish',
                      child: Text('Español'),
                    ),
                    PopupMenuItem<String>(
                      value: 'english',
                      child: Text('Ingles'),
                    ),
                    PopupMenuItem<String>(
                      value: 'all',
                      child: Text('Todos'),
                    ),
                  ];
                },
                onSelected: (String value) {
                  if (value == 'back') {
                    widget.flipBack(backToTop: true);
                  }
                  if (value == 'sources') {
                    _selectSources(context);
                  }
                  if (value == 'about') {
                    _aboutPage(context);
                  }
                  if (value == 'home') {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (context) => Stats()));
                  }
                  if (value == 'english') {
                    widget.loadLanguage("en");
                  }
                  if (value == 'all') {
                    widget.loadLanguage("all");
                  }
                  if (value == 'spanish') {
                    widget.loadLanguage("es");
                  }
                },
              ),
            ],
          ),
          body: GestureDetector(
            onTap: _launchURL,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: screenWidth,
                  child: widget.article.urlToImage != null &&
                          widget.article.urlToImage.trim() != ""
                      ? FadeInImage.assetNetwork(
                          placeholder: 'assets/images/1x1_transparent.png',
                          image: widget.article.urlToImage,
                          width: screenWidth,
                          height: screenWidth / 2,
                          fadeInDuration: const Duration(milliseconds: 300),
                          fit: BoxFit.cover,
                        )
                      : Container(),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    widget.article.title,
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 28.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      Text(
                        // Be sure
                        widget.article.author != null &&
                            widget.article.author.trim() != ""
                            ? widget.article.author
                            : widget.article.source,
                        style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0,left: 10),
                        child: Text(
                          widget.article.date,
                          style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                        ),
                      ),
                    ],
                  ),

                ),

                Expanded(
                  child: widget.article.description != null &&
                          widget.article.description.trim() != ""
                      ? Padding(
                          padding: EdgeInsets.all(10.0),
                          child: LayoutBuilder(builder: (BuildContext context,
                              BoxConstraints constraints) {
                            var maxLines =
                                ((constraints.maxHeight / 18.0).floor() - 1);
                            return maxLines > 0
                                ? Text(
                              _parseHtmlString(widget.article.description),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontSize: 18.0, color: Colors.black54),
                                    maxLines: maxLines,
                                  )
                                : Container();
                          }),
                        )
                      : Container(),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Expanded(child: Container()),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
