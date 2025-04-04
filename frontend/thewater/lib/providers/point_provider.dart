import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

const String baseUrl = 'http://j12c201.p.ssafy.io';

class PointModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _pointList = [];

  List<dynamic> get pointList => _pointList; // getter 함수로 pointList를 가져옴

  Future<void> getPointList() async {
    final token = await _storage.read(key: 'token');
    debugPrint("getPointList() Token: $token"); // 토큰 값 확인
    if (token == null) {
      debugPrint("getPointList() Token is null"); // 토큰이 없을 경우 처리
      return;
    }
    try {
      final url = Uri.parse('$baseUrl/api/fishing-points/all');
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        debugPrint("getPointList() 성공: ${response.body}");
        _pointList = jsonDecode(utf8.decode(response.bodyBytes))['data'];
      } else {
        debugPrint("getPointList() 실패 (${response.statusCode})");
      }
      debugPrint("Token: $token"); // 토큰 값 확인
      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");
      notifyListeners(); // 상태 변경 알림
    } catch (e) {
      debugPrint("getPointList() 예외 발생: $e"); // 예외 발생 시 처리
    }
  }
}
