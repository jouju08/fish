import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io:8081';

class FishApi {
  final _storage = const FlutterSecureStorage();
  Future<List<dynamic>> getFishCardList() async {
    final url = Uri.parse('$baseUrl/api/collection/myfish/all');
    final token = await _storage.read(key: 'token');
    debugPrint("Token: $token"); // 토큰 값 확인
    final headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(url, headers: headers);
    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");
    return jsonDecode(utf8.decode(response.bodyBytes))['data'];
  }
}
