import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:thewater/services/token_manager.dart';

const String baseUrl = 'http://j12c201.p.ssafy.io:8081/api';

class UserApi {
  Future<Map<String, dynamic>> login(String loginId, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "loginId": loginId,
      "password": password,
    });

    final response = await http.post(url, headers: headers, body: body);
    final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
    return decodedBody;
  }

  Future<Map<String, dynamic>> fetchUserInfo() async {
  debugPrint("fetchUserInfo() 함수 실행!!!!!");
  final token = await TokenManager().getToken();
  debugPrint("Token: $token"); // 토큰 값 확인
  final url = Uri.parse('$baseUrl/users/me');
  final headers = {
    'Authorization': 'Bearer $token',
  };

  final response = await http.get(url, headers: headers);
  debugPrint("Response status: ${response.statusCode}");
  debugPrint("Response body: ${response.body}");

  if (response.statusCode == 200) {
    final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
    debugPrint("200 OK: $decodedBody");
    return decodedBody;
  } else {
    throw Exception('Failed to fetch user info: ${response.statusCode}');
  }
}

Future<void> logout() async {
    await TokenManager().deleteToken();
  }

}
