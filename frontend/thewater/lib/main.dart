import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/env_provider.dart';
import 'package:thewater/providers/fish_provider.dart';
import 'package:thewater/providers/guestbook_provider.dart';
import 'package:thewater/providers/point_provider.dart';
import 'package:thewater/providers/search_provider.dart';
import 'package:thewater/providers/user_provider.dart';
import 'package:thewater/screens/camera_screen.dart';
import 'package:thewater/screens/fish_card_screen.dart';
import 'package:thewater/screens/login.dart';
import 'package:thewater/screens/signup.dart';
import 'package:thewater/screens/splash.dart';
import 'package:thewater/screens/thewater.dart';
import 'package:thewater/providers/aquarium_provider.dart';
import 'package:thewater/providers/ranking_provider.dart';

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
        ChangeNotifierProvider(create: (_) => PointModel()),
        ChangeNotifierProvider(create: (_) => EnvModel()),
        ChangeNotifierProvider(create: (_) => RankingProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => GuestBookProvider()),
      ],
      child: MaterialApp(
        theme: ThemeData(
          textTheme: const TextTheme(
            bodyLarge: TextStyle(fontWeight: FontWeight.bold), // 기본 텍스트 (큰 텍스트)
            bodyMedium: TextStyle(fontWeight: FontWeight.bold), // 기본 텍스트
            bodySmall: TextStyle(fontWeight: FontWeight.bold), // 작은 텍스트
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue, // 기본 테마 색상을 파란색으로 고정
            primary: Colors.blue, // 주요 색상
            onPrimary: Colors.white, // 버튼 내부 텍스트 색상
            secondary: Colors.blueAccent, // 보조 색상
          ),
          useMaterial3: true, // 최신 Material3 스타일 적용
          primarySwatch: Colors.blue,
          fontFamily: 'GrandifloraOne-regular', // 폰트 설정
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Colors.blue, // FAB 색상
          ),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/': (context) => const TheWater(pageIndex: 0),
          '/camera': (context) => const CameraScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/fish_cards': (context) => FishCardScreen(),
        },
        initialRoute: '/splash',
      ),
    );
  }
}
