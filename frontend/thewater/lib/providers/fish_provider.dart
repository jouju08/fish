import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

const String baseUrl = 'http://j12c201.p.ssafy.io/api';

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
    final url = Uri.parse('$baseUrl/collection/myfish/all');
    final headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      debugPrint("getFishCardList() 성공: ${response.body}");
      _fishCardList = jsonDecode(utf8.decode(response.bodyBytes))['data'];
    } else {
      debugPrint("getFishCardList() 실패 (${response.statusCode})");
    }
    debugPrint("Token: $token"); // 토큰 값 확인
    debugPrint("Response status: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");
    notifyListeners(); // 상태 변경 알림
  }

  void addFishCard(String fishName, int realSize, File imageFile) async {
    Dio dio = Dio();
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("getFishCardList() Token is null"); // 토큰이 없을 경우 처리
      return;
    }
    final url = Uri.parse('$baseUrl/api/collection/myfish/all').toString();
    final fishCard = {
      "fishName": fishName,
      "fishingPointId": 1,
      "realSize": realSize,
      "sky": 0,
      "temperature": 0,
      "waterTemperature": 0,
      "latitude": 0,
      "longitude": 0,
      "tide": 0,
      "comment": "string",
      "hasVisible": true,
    };
    // FormData 생성
    FormData formData = FormData.fromMap({
      "fishCard": jsonEncode(fishCard), // JSON을 String으로 변환 후 추가
      "image": await MultipartFile.fromFile(imageFile.path),
    });
    try {
      // API 요청
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Content-Type": "multipart/form-data",
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        debugPrint("addFishCard() 성공: ${response.data}");
      } else {
        debugPrint(
          "addFishCard() 실패 (${response.statusCode}): ${response.data}",
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint("addFishCard() 예외 발생: $e");
    }
  }

  void deleteFishCard(int cardId) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("getFishCardList() Token is null"); // 토큰이 없을 경우 처리
      return;
    }
    final url = Uri.parse('$baseUrl/api/collection/myfish/delete/$cardId');
    final headers = {'Authorization': 'Bearer $token'};
    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 200) {
      debugPrint("deleteFishCard() 성공: ${response.body}");
    } else {
      debugPrint("deleteFishCard() 실패 (${response.statusCode})");
    }
  }
}
