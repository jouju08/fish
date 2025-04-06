import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:thewater/providers/fish_provider.dart';
import 'package:thewater/providers/point_provider.dart';

const String baseUrl = 'http://j12c201.p.ssafy.io/api';

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
  int get id => _id;
  String get loginId => _loginId;
  String get birthday => _birthday;
  String get nickname => _nickname;
  String get email => _email;
  String get loginType => _loginType;
  bool get isLoggedIn => _isLoggedIn;

  Future<String?> get token async {
    return await _storage.read(key: 'token');
  }

  /// 로그인
  Future<bool> login(String loginId, String password) async {
    try {
      final url = Uri.parse('$baseUrl/users/login');
      final headers = {'Content-Type': 'application/json'};
      final body = jsonEncode({"loginId": loginId, "password": password});

      final response = await http.post(url, headers: headers, body: body);
      final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));

      await _storage.write(key: 'token', value: decodedBody['data']['token']);
      await fetchUserInfo(); // fetchUserInfo가 완료될 때까지 기다림

      notifyListeners(); // 상태 변경을 알림
      return decodedBody['data']['success'];
    } catch (e) {
      debugPrint("login() 오류: $e");
      return false; // 로그인 실패 시 false 반환
    }
  }

  /// 사용자 정보 가져오기
  Future<void> fetchUserInfo() async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("fetchUserInfo() Token is null"); // 토큰이 없을 경우 처리
      return;
    }
    try {
      debugPrint("fetchUserInfo 의 토큰 확인: $token");
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
        notifyListeners();
      } else {
        throw Exception('fetchuser 오류: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("fetchUserInfo() 오류: $e");
    }
  }

  /// 로그아웃
  void logout(BuildContext context) {
    debugPrint("UserModel().logout() 함수 실행");
    _storage.delete(key: 'token');
    _id = 0;
    _loginId = '';
    _nickname = '익명의 사용자';
    _birthday = '';
    _loginType = '';
    _email = '';
    _isLoggedIn = false;

    // FishModel 접근해서 리스트 초기화
    final fishModel = Provider.of<FishModel>(context, listen: false);
    fishModel.clearFishCardList();

    final pointModel = Provider.of<PointModel>(context, listen: false);
    pointModel.clearPointList();

    notifyListeners();
  }
}
