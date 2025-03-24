import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:thewater/models/fish_provider.dart';
import 'package:thewater/screens/login.dart';
import 'package:thewater/screens/model_screen.dart';
import 'screens/camera_screen.dart';
import 'package:thewater/screens/thewater.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.cameras});

  final List<CameraDescription> cameras;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => FishProvider())],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'GrandifloraOne-Regular',
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.blue, // FAB 색상
          ),
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          '/': (context) => TheWater(cameras: cameras),
          '/camera': (context) => CameraScreen(cameras: cameras),
          '/model': (context) => ModelScreen(),
        },
        initialRoute: '/',
      ),
    );
  }
}
