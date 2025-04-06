// guestbook_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://j12c201.p.ssafy.io/api';

class GuestBookProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 방명록 읽기 (특정 수족관의 방명록 목록)
  Future<List<dynamic>> fetchGuestBookEntries(int aquariumId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/guest-book/read/$aquariumId');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return body['data'];
    } else {
      throw Exception('Failed to load guestbook entries: ${response.statusCode}');
    }
  }

  // 방명록 작성
  Future<bool> writeGuestBook(int aquariumId, String content) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/guest-book/write/$aquariumId');

    final response = await http.post(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"content": content}));

    return response.statusCode == 200;
  }

  // 방명록 수정
  Future<bool> editGuestBook(int guestBookId, String newContent) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/guest-book/edit/$guestBookId');

    final response = await http.put(url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({"content": newContent}));

    return response.statusCode == 200;
  }

  // 방명록 삭제
  Future<bool> deleteGuestBook(int guestBookId) async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/guest-book/remove/$guestBookId');

    final response = await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    return response.statusCode == 200;
  }

  // 자신의 방명록 읽기
  Future<List<dynamic>> fetchMyGuestBook() async {
    final token = await _storage.read(key: 'token');
    final url = Uri.parse('$baseUrl/guest-book/read/me');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(utf8.decode(response.bodyBytes));
      return body['data'];
    } else {
      throw Exception('Failed to load my guestbook entries: ${response.statusCode}');
    }
  }
}