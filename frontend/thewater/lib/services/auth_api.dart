import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'https://j12c201.p.ssafy.io/api';

class AuthApi {
  Future<Map<String, dynamic>> checkIdAvailability(String loginId) async {
    final url = Uri.parse(
      '$baseUrl/users/check-id?login_id=$loginId',
    ); //Uri 객체로 사용하는 이유는 URL 을 안전하게 다룰 수 있는 여러 기능을 제공하기 때문이다.
    try {
      final response = await http.get(url);
      if (response.statusCode == 200 || response.statusCode == 409) {
        return jsonDecode(response.body);
      } else {
        return {'available': false, 'message': '이미 사용중인 아이디입니다.'};
      }
    } catch (e) {
      print(e);
      return {'available': false, 'message': '이미 사용중인 아이디입니다.'};
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