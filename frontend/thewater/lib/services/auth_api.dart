import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://j12c201.p.ssafy.io/api';

class AuthApi {
  Future<bool> checkIdAvailability(String loginId) async {
    final url = Uri.parse(
      '$baseUrl/users/check-id?login_id=$loginId',
    ); //Uri 객체로 사용하는 이유는 URL 을 안전하게 다룰 수 있는 여러 기능을 제공하기 때문이다.
    try {
      final response = await http.get(url);
      final json = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 409) {
        debugPrint("이메일 중복체크 완료");
        return json['available'];
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("이메일 중복 체크 중 오류 발생");
      return true;
    }
  }

  Future<List<dynamic>> getFishList(String userId) async {
    final url = Uri.parse('$baseUrl/fish');
    final headers = <String, String>{};
    final body = jsonEncode({
      'kakaoAccessToken': 'kakaoAccessToken',
      'fcmNotificationToken': 'fcmToken',
    });
    final response = await http.post(url, headers: headers, body: body);
    final json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      debugPrint("물고기 목록 조회 성공");

      return json['data'];
    } else {
      debugPrint("물고기 목록 조회 실패! json: $json");
      throw Exception('lib/services/auth_api.dart');
    }
  }
}
    // var url = Uri.parse('$_baseUrl/user/profile/$userId');
    // var headers = {'Content-Type': 'application/json'};
    // var body = json.encode({
    //   'height': height,
    //   'weight': weight,
    //   'nickname': nickname,
    // });
    // var response = await http.patch(url, headers: headers, body: body);