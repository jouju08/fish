import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io:8081/api';

class FishModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _fishCardList = [];
  List<dynamic> get fishCardList =>
      _fishCardList; // getter 함수로 fishCardList를 가져옴

  void getFishCardList() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("getFishCardList() Token is null"); // 토큰이 없을 경우 처리
      return;
    }
    final url = Uri.parse('$baseUrl/api/collection/myfish/all');
    final headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(url, headers: headers);
    debugPrint("Token: $token"); // 토큰 값 확인
    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");
    _fishCardList = jsonDecode(utf8.decode(response.bodyBytes))['data'];
  }
}
