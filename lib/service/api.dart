import 'dart:async';
import 'dart:convert';

import 'package:shiba/keys.dart';
import 'package:shiba/model/source.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

class Api {
  final String _baseUrl = "http://api.develop.socialtimeapp.com";

  Future<String> getArticles({
    @required String sources,
    @required int page,
    @required int pageSize,
    @required String param,
  }) async {
    String url = Uri.encodeFull(_baseUrl +
        '/general/news?sources=$sources&pageSize=$pageSize&page=$page&param=$param');
    try {
      http.Response response = await http.get(url, headers: _headers());
      if (response.statusCode == 200) {
        print("aqui esta body ${response.body}");
        return response.body;
      }
    } on Exception {}
    return null;
  }

  Future<List<Source>> getSources() async {
    String url = Uri.encodeFull(_baseUrl + 'sources');
    try {
      http.Response response = await http.get(url, headers: _headers());
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data != null && data["sources"] != null) {
          List<Source> sources = (data["sources"] as List<dynamic>)
              .map((source) => Source.fromJson(source))
              .toList();
          return sources;
        }
      }
    } on Exception {}
    return null;
  }

  Map<String, String> _headers() {
    return {
      "Accept": "application/json",
      "X-Api-Key": NEWSAPI_KEY,
    };
  }
}
