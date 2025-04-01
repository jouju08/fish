import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io:8081/api';

class UserModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  int _id = 0;
  String _loginId = '';
  String _nickname = '익명의 사용자';
  String _email = '';
  String _birthday = '';
  String _loginType = '';
  bool _isLoggedIn = false;

  // Getters
  int get id => _id; //getter 함수로 _id를 가져옴
  String get loginId => _loginId;
  String get birthday => _birthday;
  String get nickname => _nickname;
  String get email => _email;
  String get loginType => _loginType;
  bool get isLoggedIn => _isLoggedIn;

  void login(String loginId, String password) async {
    final url = Uri.parse('$baseUrl/users/login');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({"loginId": loginId, "password": password});

    final response = await http.post(url, headers: headers, body: body);
    final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));
    await _storage.write(key: 'token', value: decodedBody['data']['token']);
    fetchUserInfo();

    notifyListeners(); // 상태 변경을 알림
  }

  void fetchUserInfo() async {
    final token = await _storage.read(key: 'token');
    debugPrint("Token: $token"); //토큰 값 확인
    final url = Uri.parse('$baseUrl/users/me');
    final headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(url, headers: headers);
    debugPrint("Response status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      debugPrint("200 OK: $body");
      _id = body['data']['id'];
      _loginId = body['data']['loginId'];
      _nickname = body['data']['nickname'];
      _loginType = body['data']['loginType'];
      _email = body['data']['email'];
      _birthday = body['data']['birthday'];
      _isLoggedIn = true;
      return;
    } else {
      throw Exception('fetchuser 오류: ${response.statusCode}');
    }
  }

  void logout() {
    debugPrint("UserModel().logout() 함수 실행");
    _storage.delete(key: 'token');
    _id = 0;
    _loginId = '';
    _nickname = '익명의 사용자';
    _birthday = '';
    _loginType = '';
    _email = '';
    _isLoggedIn = false;

    notifyListeners(); // 상태 변경을 알림
  }
}
