import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/user_provider.dart';
import 'package:thewater/screens/login.dart';
import 'package:thewater/screens/thewater.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // 로딩 표시를 위한 짧은 딜레이
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // 로그인 상태에 따라 화면 전환
    if (Provider.of<UserModel>(context).isLoggedIn) {
      return const TheWater(pageIndex: 0);
    } else {
      return const LoginScreen();
    }
  }
}
