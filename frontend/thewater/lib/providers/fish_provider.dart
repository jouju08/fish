import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:dio/dio.dart';

const String baseUrl = 'http://j12c201.p.ssafy.io/api';

class FishModel extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  List<dynamic> _fishCardList = [];
  List<dynamic> get fishCardList =>
      _fishCardList; // getter 함수로 fishCardList를 가져옴

  Future<void> getFishCardList() async {
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

  void clearFishCardList() {
    _fishCardList = [];
    notifyListeners();
  }

  void toggleFishVisibility(int fishId) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("❌ 토큰이 없습니다.");
      return;
    }

    final url = Uri.parse('$baseUrl/aquarium/visible/$fishId');
    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    final response = await http.patch(url, headers: headers);

    if (response.statusCode == 200) {
      debugPrint("✅ hasVisible 토글 성공 (id: $fishId)");
      getFishCardList(); // 서버 데이터 최신화
    } else {
      debugPrint(
        "❌ hasVisible 토글 실패 fishId : $fishId (${response.statusCode}), 응답내용: ${response.body}",
      );
    }
  }

  void addFishCard(String fishName, int realSize, File imageFile) async {
    Dio dio = Dio();
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("getFishCardList() Token is null"); // 토큰이 없을 경우 처리
      return;
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
    final url = Uri.parse('$baseUrl/collection/myfish/add').toString();
    final fishCard = {
      "fishName": fishName,
      "fishSize": realSize,
      "sky": 0,
      "temperature": 0,
      "waterTemperature": 0,
      "latitude": position.latitude,
      "longitude": position.longitude,
      "tide": 0,
      "comment": "memo",
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
        await getFishCardList(); // 전체 리스트 다시 불러오기
        notifyListeners();
      } else {
        debugPrint(
          "addFishCard() 실패 (${response.statusCode}): ${response.data}",
        );
      }
    } catch (e) {
      debugPrint("addFishCard() 예외 발생: $e");
    }
  }

  void deleteFishCard(BuildContext context, int cardId) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("getFishCardList() Token is null"); // 토큰이 없을 경우 처리
      return;
    }
    final url = Uri.parse('$baseUrl/collection/myfish/delete/$cardId');
    final headers = {'Authorization': 'Bearer $token'};
    final response = await http.delete(url, headers: headers);
    if (response.statusCode == 200) {
      debugPrint("deleteFishCard() 성공: ${response.body}");
      await getFishCardList();
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('물고기 카드를 삭제했습니다')));
    } else {
      debugPrint("deleteFishCard() 실패 (${response.statusCode})");
    }

    notifyListeners();
  }

  Future<Uint8List> fetchImageBytes(String filename) async {
    final token = await _storage.read(key: 'token');
    if (token == null) {
      debugPrint("getFishCardList() Token is null"); // 토큰이 없을 경우 처리
    }
    final headers = {'Authorization': 'Bearer $token'};
    final url = Uri.parse("$baseUrl/collection/myfish/image/$filename");
    final response = await http.get(url, headers: headers);
    debugPrint("filename $filename ");
    if (response.statusCode == 200) {
      return response.bodyBytes; // ← 이미지 바이트 데이터
    } else {
      debugPrint("fetchImage 오류 ${response.statusCode}");
      throw Exception('이미지 가져오기 실패');
    }
  }
}
