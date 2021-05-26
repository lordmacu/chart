import 'dart:io';
import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:k_chart/chart_style.dart';
import 'package:k_chart/flutter_k_chart.dart';
import 'package:shiba/model/article.dart';
import 'package:shiba/push_notifications.dart';
import 'package:shiba/ui/article_page.dart';
import 'package:shiba/ui/home_articles.dart';
import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money2/money2.dart';


class Stats extends StatefulWidget {
  @override
  StatsState createState() => StatsState();
}

class StatsState extends State<Stats> {
  var stats;
  var price = "0";
  var percentaje = "0";
  var type = "";
  var capitalization = "";
  var volume = "";
  var volume_cap = "";
  var maximun_minimun = "";
  var minimum_low = "";
  var clasification = "";
  var maximun_historic = "";
  var minimum_historic = "";
  var latestFech = 0;
  bool isShowInput=false;

  DateTime latest;
  bool showLoading = false;
  bool isNotificationGeneral = false;
  bool isLoading = false;
  Timer timer;
  Timer timers;
  List<SalesData> statsData = [];
  List<double> xstatsData = [];
  MainState _mainState = MainState.MA;
  List<KLineEntity> datas = [];
  String totalShib = "";
  double myShibasGeneral=0;

  SecondaryState _secondaryState = SecondaryState.MACD;

  ChartStyle chartStyle = new ChartStyle();
  ChartColors chartColors = new ChartColors();

  final fromDate = DateTime(2021, 05, 22);
  final toDate = DateTime.now();

  final date1 = DateTime.now().subtract(Duration(days: 2));
  final date2 = DateTime.now().subtract(Duration(days: 3));

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  var pushNotificationService;

  @override
  void initState() {
    super.initState();
    pushNotificationService = PushNotificationService(_firebaseMessaging);
    pushNotificationService.initialise();


    getData("1mon");
    setNotfication();
    loading();
    loadStats();

    timer = Timer.periodic(Duration(seconds: 7), (Timer t) => loadStats());
    timers = Timer.periodic(Duration(seconds: 4), (Timer t) => getData("1min"));
  }

  Future setNotfication() async {


    SharedPreferences prefs = await SharedPreferences.getInstance();


    setState(() {
      myShibasGeneral=  prefs.getDouble("myshibas");
    });



    bool isNotification = prefs.getBool("showNotifications");

    print("aqui esta la notification  ${isNotification}");

    if (isNotification == null) {
      pushNotificationService.subscribe();

      prefs.setBool("showNotifications", true);
      setState(() {
        isNotificationGeneral = true;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    timers?.cancel();
    super.dispose();
  }

  Future loadStats() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    DateTime now = new DateTime.now();

    if (latest != null) {
      Duration diference = now.difference(latest);
      var formatter = new DateFormat('hh-mm-ss');
      String formattedDate = formatter.format(now);

      setState(() {
        latestFech = diference.inSeconds;
      });
    } else {
      latest = now;
    }

    setState(() {
      latestFech = 0;
    });
    //  prefs.setString("time", value)
    var url =
        Uri.parse('http://api.develop.socialtimeapp.com/general/getDatacoin');
    var response = await http.get(url);
    stats = json.decode(response.body);
    var data = stats["data"];

    print("cargando ..");

    data.forEach((item) {
      if (item["title"] == "price") {
        setState(() {
          price = item["value"];
        });
      }

      if (item["title"] == "percentaje") {
        setState(() {
          percentaje = item["value"];
        });
      }
      if (item["title"] == "type") {
        setState(() {
          type = item["value"];
        });
      }

      if (item["title"] == "volume_cap") {
        setState(() {
          volume_cap = item["value"];
        });
      }

      if (item["title"] == "maximun_minimun") {
        setState(() {
          maximun_minimun = item["value"];
        });
      }

      if (item["title"] == "capitalization") {
        setState(() {
          capitalization = item["value"];
        });
      }

      if (item["title"] == "minimum_historic") {
        setState(() {
          minimum_historic = item["value"];
        });
      }

      if (item["title"] == "minimum_low") {
        setState(() {
          minimum_low = item["value"];
        });
      }

      if (item["title"] == "clasification") {
        setState(() {
          clasification = item["value"];
        });
      }

      if (item["title"] == "maximun_historic") {
        setState(() {
          maximun_historic = item["value"];
        });
      }

      if (item["title"] == "volume") {
        setState(() {
          volume = item["value"];
        });
      }
    });
    changePrice();

    setState(() {
      isLoading = false;
    });
  }

  loading() {
    setState(() {
      isLoading = true;
    });
  }

  _launchNewsApiURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void getData(String period) {
    Future<String> future = getIPAddress('$period');
    future.then((result) {
      Map parseJson = json.decode(result);
      List list = parseJson['data'];
      setState(() {
        datas = list
            .map((item) => KLineEntity.fromJson(item))
            .toList()
            .reversed
            .toList()
            .cast<KLineEntity>();
        DataUtil.calculate(datas);
        showLoading = false;
      });

      setState(() {});
    }).catchError((_) {
      showLoading = false;
      setState(() {});
      print('获取数据失败');
    });
  }

  //获取火币数据，需要翻墙
  Future<String> getIPAddress(String period) async {
    var url =
        'https://api.huobi.br.com/market/history/kline?period=${period ?? '15min'}&size=30&symbol=shibusdt';
    String result;
    var response = await http.get(url);
    if (response.statusCode == 200) {
      result = response.body;
    } else {
      print('Failed getting IP address');
    }
    return result;
  }

  changePrice() async{
    SharedPreferences prefs =
    await SharedPreferences.getInstance();
   double shibas=  prefs.getDouble("myshibas");

   if(shibas!=null){

     double dValuePrice = double.tryParse(price
         .replaceAll("\$", "")
         .replaceAll(",", ".")
         .replaceAll(" ", ""));

     setState(() {
       Currency usdCurrency =
       Currency.create('USD', 2);

       final currencyFormatter =
       NumberFormat.currency(locale: 'en');

       totalShib =
       "${currencyFormatter.format(shibas * dValuePrice)}";
     });
   }

    print("estas son mis shibas  ${shibas}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff171e26),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(top: 60),
                child: Column(
                  children: [
                    Center(
                      child: Image.asset(
                        'assets/images/shib_logo_header.png',
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      child: Text(
                        "Shiba Token",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(30.0)),
                        color: Colors.deepOrange,
                        child: Text(
                          "Noticias",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => HomeArticles("all")));
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(top: 30),
                      decoration: BoxDecoration(
                          color: Color(0xff1f2630),
                          borderRadius: BorderRadius.only(
                              topRight: Radius.circular(30),
                              topLeft: Radius.circular(30))),
                      child: Column(
                        children: [
                          price != "0"
                              ? Container(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        child: Column(
                                          children: [
                                            Text(
                                              "${price}",
                                              style: TextStyle(
                                                  fontSize: 40,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            top: 5,
                                            bottom: 5),
                                        decoration: BoxDecoration(
                                            color: type == "text-green"
                                                ? Colors.green
                                                : Colors.redAccent,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10))),
                                        margin: EdgeInsets.only(top: 0),
                                        child: Text(
                                          "${percentaje}",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            child: RaisedButton(
                              onPressed: () {
                                setState(() {
                                  isShowInput=!isShowInput;
                                });
                              },
                              color: Colors.white,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Icon(Icons.refresh),
                                  ),
                                  Text(
                                    totalShib == ""
                                        ? "Calcular Shib"
                                        : "${totalShib}",
                                    style: TextStyle(fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          ),
                          isShowInput ? Container(
                            padding:
                                EdgeInsets.only(left: 20, right: 20, top: 10),
                            child: Stack(
                              children: [
                                TextFormField(
                                  initialValue: "${myShibasGeneral}",

                                    maxLines: 1,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      CurrencyTextInputFormatter(
                                          decimalDigits: 0, locale: "es")
                                    ],
                                    onChanged: (value) async {


                                      if(value!=null){


                                        double dValue = double.tryParse(value
                                            .replaceAll("\$", "")
                                            .replaceAll(".", "")
                                            .replaceAll(",", "")
                                            .replaceAll(" ", ""));

                                        SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                        prefs.setDouble("myshibas", dValue);

                                        double dValuePrice = double.tryParse(price
                                            .replaceAll("\$", "")
                                            .replaceAll(",", ".")
                                            .replaceAll(" ", ""));

                                        setState(() {
                                          Currency usdCurrency =
                                          Currency.create('USD', 2);

                                          final currencyFormatter =
                                          NumberFormat.currency(locale: 'en');

                                          totalShib =
                                          "${currencyFormatter.format(dValue * dValuePrice)}";
                                        });
                                      }
                                    },
                                    decoration: InputDecoration(

                                      border: InputBorder.none,
                                      hintText: 'Ingresa el número a calcular',
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: const EdgeInsets.only(
                                          left: 14.0, bottom: 6.0, top: 8.0),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(color: Colors.white),
                                        borderRadius: BorderRadius.circular(10.0),
                                      ),
                                    )),
                                Positioned(child: GestureDetector(
                                  onTap: (){
                                    print("sadfasdf");
                                  setState(() {
                                    isShowInput=!isShowInput;
                                  });

                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
                                      color: Colors.green

                                    ),
                                    padding: EdgeInsets.only(top: 12,bottom: 12,left: 12,right: 12),
                                    child: Icon(Icons.check,color: Colors.white,),
                                  ),
                                ),
                                  right: 0,

                                )
                              ],
                            ),
                          ): Container(),
                          price != "0"
                              ? Container(
                                  margin: EdgeInsets.only(top: 20),
                                  child: Column(
                                    children: [
                                      datas.length > 0
                                          ? Container(
                                              height: 300,
                                              child: KChartWidget(
                                                datas,
                                                chartStyle,
                                                chartColors,
                                                isLine: true,
                                                mainState: _mainState,
                                                volHidden: true,
                                                secondaryState: _secondaryState,
                                                fixedLength: 10,
                                                timeFormat:
                                                    TimeFormat.YEAR_MONTH_DAY,
                                                isChinese: false,
                                              ))
                                          : Container(),
                                    ],
                                  ),
                                )
                              : Container(),
                          price != "0"
                              ? Container(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(top: 20),
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 20, bottom: 20),
                                          child: Column(
                                            children: [
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Container(
                                                        child: Text(
                                                          "Capitalización de mercado",
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      flex: 5,
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 5,
                                                          bottom: 5),
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Text(
                                                        "${capitalization}",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                      child: Text(
                                                        "Dominio de capitalización de mercado",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 5,
                                                          bottom: 5),
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Text(
                                                        "${capitalization}",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                      child: Text(
                                                        "Volumen de comercio",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 10,
                                                          right: 10,
                                                          top: 5,
                                                          bottom: 5),
                                                      margin: EdgeInsets.only(
                                                          top: 10),
                                                      child: Text(
                                                        "${volume}",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          child: Text(
                                                            "Volumen / Cap. de mercado",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        )),
                                                    Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 5,
                                                                  bottom: 5),
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 10),
                                                          child: Text(
                                                            "${volume_cap}",
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          child: Text(
                                                            "Clasificación de capitalización de mercado	 ",
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        )),
                                                    Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 10,
                                                                  right: 10,
                                                                  top: 5,
                                                                  bottom: 5),
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 10),
                                                          child: Text(
                                                            "${clasification}",
                                                            textAlign:
                                                                TextAlign.right,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ))
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                      child: Text(
                                                        "Mínimo en 24 h / Máximo en 24 h",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                right: 10,
                                                                top: 5,
                                                                bottom: 5),
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        child: Text(
                                                          "${maximun_minimun}",
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                      child: Text(
                                                        "Mínimo en 7 días / Máximo en 7 días",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                right: 10,
                                                                top: 5,
                                                                bottom: 5),
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        child: Text(
                                                          "${minimum_low}",
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                      child: Text(
                                                        "Máximo histórico	",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                right: 10,
                                                                top: 5,
                                                                bottom: 5),
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        child: Text(
                                                          "${maximun_historic}",
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                        child: Container(
                                                      child: Text(
                                                        "Mínimo histórico	",
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    )),
                                                    Expanded(
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 10,
                                                                right: 10,
                                                                top: 5,
                                                                bottom: 5),
                                                        margin: EdgeInsets.only(
                                                            top: 10),
                                                        child: Text(
                                                          "${minimum_historic}",
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : Container(
                                  child: Text("Cargando..."),
                                )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              right: 0,
              top: 35,
              child: GestureDetector(
                onTap: () {
                  _launchNewsApiURL("https://t.me/Shiba_Inu_Spain");
                },
                child: Container(
                  width: 80,
                  child: Image.asset(
                    'assets/images/logo.png',
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              top: 35,
              child: GestureDetector(
                onTap: () async {
                  if (!isNotificationGeneral) {
                    pushNotificationService.subscribe();

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    bool isNotification = prefs.getBool("showNotifications");

                    prefs.setBool("showNotifications", true);
                    setState(() {
                      isNotificationGeneral = true;
                    });
                  } else {
                    pushNotificationService.unSubscribe();

                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    prefs.setBool("showNotifications", false);
                    setState(() {
                      isNotificationGeneral = false;
                    });
                  }
                },
                child: Container(
                  width: 80,
                  child: Icon(
                    !isNotificationGeneral
                        ? Icons.notifications_none
                        : Icons.notifications,
                    size: 40,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
