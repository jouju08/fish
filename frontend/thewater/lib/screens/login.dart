import 'package:flutter/material.dart';
import 'package:thewater/services/user_api.dart';
import 'package:thewater/screens/signup.dart';
import 'package:thewater/services/token_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage;
  bool _isLoading = false;
  final TokenManager _tokenManager = TokenManager();

  void _login() async {
    setState(() {
      errorMessage = null;
      _isLoading = true;
    });

    final loginId = _loginIdController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await UserApi().login(loginId, password);
      // 응답 예시:
      // {
      //   "status": "SU",
      //   "message": "Success.",
      //   "data": {
      //     "success": true,
      //     "message": "로그인 성공",
      //     "token": "eyJhbGciOiJIUzUxMiJ9..."
      //   }
      // }

      if (response['status'] == 'SU' &&
          response['data'] != null &&
          response['data']['success'] == true) {
        // 로그인 성공: token 저장
        final token = response['data']['token'];
        debugPrint("로그인 성공 데이터: ${response['data']}");
        await _tokenManager.saveToken(token);
        // 사용자 데이터 가져오기
        await _getUserData();
        // 메인 페이지('/')로 이동
        Navigator.pushReplacementNamed(context, '/');
      } else {
        setState(() {
          errorMessage = "아이디 또는 비밀번호가 잘못되었습니다.";
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "로그인 중 오류가 발생했습니다.";
        debugPrint("로그인 실패: $e");
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getUserData() async {
    debugPrint("_getUserData() 함수 실행!!!!");
    try {
      final userData = await UserApi().fetchUserInfo();
      debugPrint("User data: $userData");
    } catch (e) {
      debugPrint("User data 가져오기 실패: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 필요시 AppBar 등 추가 가능
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 중앙 로고 이미지
                  Image.asset(
                    'assets/icon/로그인로고.png',
                    width: 200,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 40),
                  // 아이디 입력 필드
                  TextField(
                    controller: _loginIdController,
                    decoration: const InputDecoration(
                      labelText: '아이디',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 비밀번호 입력 필드
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: '비밀번호',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignupScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      '이메일로 회원가입',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 에러 메시지 (로그인 실패 시 빨간색 텍스트)
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  const SizedBox(height: 20),
                  // "다음" 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                '다음',
                                style: TextStyle(fontSize: 18),
                              ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  // 카카오톡 로그인 아이콘
                  GestureDetector(
                    onTap: () {
                      // TODO: 카카오톡 로그인 로직 추가
                    },
                    child: Image.asset(
                      'assets/icon/카카오공유아이콘.png',
                      width: 60,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
