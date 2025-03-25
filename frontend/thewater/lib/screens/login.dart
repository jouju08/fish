import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thewater/services/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _verificationCodeController =
      TextEditingController();
  String? _idCheckMessage;

  void _checkIdAvailability() async {
    debugPrint("아이디 중복체크 버튼 클릭");
    // bool isValid = await AuthApi().checkIdAvailability(
    //   _idController.text.trim(),
    // );
    bool isValid = true;
    setState(() {
      _idCheckMessage = isValid ? "사용 가능한 아이디입니다." : "이미 사용 중인 아이디입니다.";
    });
    // 아이디 중복 확인 기능 (추후 API 연결 가능)
    print("아이디 중복 확인: ${_idController.text}");
  }

  void _sendVerificationCode() {
    // 이메일 인증번호 발송 기능 (추후 API 연결 가능)
    print("이메일 인증번호 발송: ${_emailController.text}");
  }

  void _verifyCode() {
    // 인증번호 확인 기능 (추후 API 연결 가능)
    print("인증번호 확인: ${_verificationCodeController.text}");
  }

  void _nextStep() {
    // 다음 버튼 클릭 시 동작 (회원가입 진행)
    print("회원가입 진행");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1️⃣ 아이디 입력란 + 중복 확인 버튼
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      decoration: InputDecoration(
                        labelText: '아이디 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _checkIdAvailability,
                    child: Text('중복 확인'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (_idCheckMessage != null)
                Text(
                  _idCheckMessage!,
                  style: TextStyle(
                    color:
                        _idCheckMessage == "사용 가능한 아이디입니다."
                            ? Colors.green
                            : Colors.red,
                    fontSize: 14,
                  ),
                ),

              // 2️⃣ 비밀번호 입력란
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호 입력',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              // 3️⃣ 비밀번호 확인 입력란
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '비밀번호 확인',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),

              // 4️⃣ 이메일 입력란 + 인증번호 발송 버튼
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: '이메일 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _sendVerificationCode,
                    child: Text('인증번호 발송'),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // 5️⃣ 인증번호 입력란 + 확인 버튼
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _verificationCodeController,
                      decoration: InputDecoration(
                        labelText: '인증번호 입력',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: _verifyCode, child: Text('확인')),
                ],
              ),
              SizedBox(height: 20),

              // 6️⃣ 다음 버튼
              ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text('다음'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
