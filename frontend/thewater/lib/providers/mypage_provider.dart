import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

const String baseUrl = "http://j12c201.p.ssafy.io/api";

class MypageProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();

  String _nickname = '';
  String _loginId = '';
  String _latestFishDate = '';
  String _latestFishLocation = '';
  int _totalFishCaught = 0;

  String get nickname => _nickname;
  String get loginId => _loginId;
  String get latestFishDate => _latestFishDate;
  String get latestFishLocation => _latestFishLocation;
  int get totalFishCaught => _totalFishCaught;

  Future<String?> get token async {
    return await _storage.read(key: 'token');
  }

  Future<void> getMyPage() async {
    final token = await _storage.read(key: 'token');
    if(token == null) {
      debugPrint('getMyPage() : 유저 토큰 실패');
      return;
    }
    try {
      debugPrint("getMyPage() 토큰 확인 : $token");
      final url = Uri.parse("$baseUrl/users/mypage");
      final headers = {'Authorization': 'Bearer $token'};
      final response = await http.get(url, headers: headers);
      debugPrint("Response status: ${response.statusCode}");

      if(response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        _nickname = body['data']['nickname'];
        _loginId = body['data']['loginId'];
        _latestFishDate = body['data']['latestFishDate'];
        _latestFishLocation = body['data']['latestFishLocation'];
        _totalFishCaught = body['data']['totalFishCaught'];
        notifyListeners();
      } else {
        throw Exception('getMypage 오류 : ${response.statusCode}');
      }
    } catch (error) {
      debugPrint("getMyPage() 오류 $error");
    }
  }

}
