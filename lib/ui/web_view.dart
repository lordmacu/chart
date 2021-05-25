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
class WebViewPage extends StatefulWidget {
  Article article;
  WebViewPage(this.article);
  @override
  WebViewState createState() => WebViewState();
}

class WebViewState extends State<WebViewPage> {
  DateTime tempDate;
  var date;
  var StringUrl;
  WebViewController controller;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();


       tempDate = new DateFormat("yyyy-MM-dd hh:mm", 'en_US').parse( this.widget.article.date);

     date = DateFormat.yMMMMd('es').format(tempDate);
    StringUrl=widget.article.url;

    print("aqui esta la imagen ${widget.article.urlToImage}");

  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        title: Text("${date}"),
          automaticallyImplyLeading: false,

          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);

            },
            child: Icon(
              Icons.arrow_back_ios,  // add custom icons also
            ),
          ),
          actions: <Widget>[
            Container(

                child: InkWell(
                  onTap: () {
                    launch("https://translate.google.com/translate?js=n&sl=auto&tl=es&u=${Uri.encodeComponent(this.StringUrl)}");

                  },
                  child: Container(
                    padding: EdgeInsets.only(right: 10.0,left:10,top: 17),

                    child: Text("ES",style: TextStyle(fontSize: 17),),
                  ),

                )
            ),
            Container(

                child: InkWell(
                  onTap: () {
                    launch("https://translate.google.com/translate?js=n&sl=auto&tl=en&u=${Uri.encodeComponent(this.StringUrl)}");


                  },
                  child: Container(
                    padding: EdgeInsets.only(right: 10.0,left:10,top: 17),

                    child: Text("EN",style: TextStyle(fontSize: 17),),
                  ),

                )
            ),
          ]
      ),
      body: WebView(



        initialUrl: '${StringUrl}',

          javascriptMode: JavascriptMode.disabled,

          onWebViewCreated: (WebViewController webViewController) {
            controller = webViewController;}

      ),
    );
  }
}