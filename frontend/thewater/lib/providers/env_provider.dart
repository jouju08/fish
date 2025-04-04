import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

const String baseUrl = 'http://j12c201.p.ssafy.io';

class EnvModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  Future<List<dynamic>> getTideInfoList(double lat, double lon) async {
    try {
      final token = await _storage.read(key: 'token');
      if (token == null) {
        debugPrint("getTideList() Token is null");
        return [];
      }
      final url = Uri.parse('$baseUrl/api/env-info/tide?lat=$lat&lon=$lon');
      debugPrint("getTideList() URL: $url"); // URL 확인
      debugPrint("getTideList() Token: $token"); // 토큰 값 확인
      final header = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: header);
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data']['tideInfo'];
      } else {
        debugPrint("getTideList() 실패 (${response.statusCode})");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching tide data: $e");
      return [];
    }
  }

  Future<List<dynamic>> getRiseSetList() async {
    try {
      final url = Uri.parse('$baseUrl/api/tide/riseSet/');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        return body['data'];
      } else {
        throw Exception('Failed to load rise set data');
      }
    } catch (e) {
      debugPrint("Error fetching rise set data: $e");
      return [];
    }
  }

  String _env = 'dev'; // 기본값을 'dev'로 설정
  String get env => _env;

  void setEnv(String newEnv) {
    _env = newEnv;
    notifyListeners();
  }

  Future<String?> get token async {
    return await _storage.read(key: 'token');
  }
}
