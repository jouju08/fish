import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/user_provider.dart';
import 'package:thewater/screens/signup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? errorMessage;
  final bool _isLoading = false;

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
                      // onPressed: _isLoading ? null : _login,
                      onPressed:
                          _isLoading
                              ? null
                              : () {
                                Provider.of<UserModel>(
                                  context,
                                  listen: false,
                                ).login(
                                  _loginIdController.text,
                                  _passwordController.text,
                                );
                                Navigator.pushReplacementNamed(context, '/');
                              },
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
