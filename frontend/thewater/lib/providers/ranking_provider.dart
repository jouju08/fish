// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;

// const String baseUrl = 'http://j12c201.p.ssafy.io:8081/api';

// class UserModel extends ChangeNotifier {
//   final _storage = const FlutterSecureStorage();

//   int  _aquariumId = 0;
//   int _memberId = 0;
//   String _nickname = '익명의 사용자';
//   int _totalPrice = 0;
//   String _memberComment = '';

//   // Getters
//   int get aquariumId => _aquariumId;
//   int get memberId = _memberId;

//   Future<String?> get token async {
//     return await _storage.read(key: 'token');
//   }

//   /// 로그인
//   Future<void> login(String loginId, String password) async {
//     final url = Uri.parse('$baseUrl/users/login');
//     final headers = {'Content-Type': 'application/json'};
//     final body = jsonEncode({"loginId": loginId, "password": password});

//     final response = await http.post(url, headers: headers, body: body);
//     final decodedBody = jsonDecode(utf8.decode(response.bodyBytes));

//     await _storage.write(key: 'token', value: decodedBody['data']['token']);
//     await fetchUserInfo(); // fetchUserInfo가 완료될 때까지 기다림

//     notifyListeners(); // 상태 변경을 알림
//   }

//   /// 사용자 정보 가져오기
//   Future<void> fetchUserInfo() async {
//     final token = await _storage.read(key: 'token');
//     debugPrint("fetchUserInfo 의 토큰 확인: $token");
//     final url = Uri.parse('$baseUrl/users/me');
//     final headers = {'Authorization': 'Bearer $token'};

//     final response = await http.get(url, headers: headers);
//     debugPrint("Response status: ${response.statusCode}");

//     if (response.statusCode == 200) {
//       final body = jsonDecode(utf8.decode(response.bodyBytes));
//       debugPrint("200 OK: $body");
//       _id = body['data']['id'];
//       _loginId = body['data']['loginId'];
//       _nickname = body['data']['nickname'];
//       _loginType = body['data']['loginType'];
//       _email = body['data']['email'];
//       _birthday = body['data']['birthday'];
//       _isLoggedIn = true;
//       notifyListeners();
//     } else {
//       throw Exception('fetchuser 오류: ${response.statusCode}');
//     }
//   }

//   /// 로그아웃
//   void logout() {
//     debugPrint("UserModel().logout() 함수 실행");
//     _storage.delete(key: 'token');
//     _id = 0;
//     _loginId = '';
//     _nickname = '익명의 사용자';
//     _birthday = '';
//     _loginType = '';
//     _email = '';
//     _isLoggedIn = false;

//     notifyListeners();
//   }
// }
