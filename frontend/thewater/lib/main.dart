import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/fish_provider.dart';
import 'package:thewater/providers/user_provider.dart';
import 'package:thewater/screens/camera_screen.dart';
import 'package:thewater/screens/fish_card_screen.dart';
import 'package:thewater/screens/login.dart';
import 'package:thewater/screens/signup.dart';
import 'package:thewater/screens/thewater.dart';
import 'package:thewater/providers/aquarium_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AquariumModel()),
        ChangeNotifierProvider(create: (_) => FishModel()),
        ChangeNotifierProvider(create: (_) => UserModel()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, // 기본 테마 색상을 파란색으로 고정
            primary: Colors.blue, // 주요 색상
            onPrimary: Colors.white, // 버튼 내부 텍스트 색상
            secondary: Colors.blueAccent, // 보조 색상
          ),
          useMaterial3: true, // 최신 Material3 스타일 적용
          primarySwatch: Colors.blue,
          fontFamily: 'GrandifloraOne-Regular',
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue, // FAB 색상
          ),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => const TheWater(),
          '/camera': (context) => const CameraScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/fish_cards': (context) => FishCardScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
