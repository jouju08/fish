import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/camera_page.dart';
import 'dart:async';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(
    MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.blue, // FAB 색상
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: TheWater(cameras: cameras),
    ),
  );
}

class TheWater extends StatefulWidget {
  final List<CameraDescription> cameras;
  const TheWater({super.key, required this.cameras});

  @override
  State<TheWater> createState() => _TheWaterState();
}

class _TheWaterState extends State<TheWater> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: [FirstPage(), SecondPage()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      CameraPage(cameras: widget.cameras), // 🔥 카메라 페이지 이동 추가
            ),
          );
        },
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (newIndex) {
          setState(() {
            currentIndex = newIndex;
          });
        },
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.grey[100],
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: ""),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: mainPage(),
        ),
      ),
    );
  }
}

class mainPage extends StatefulWidget {
  const mainPage({super.key});

  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  double fish1X = 50; // 첫 번째 어획물 X 좌표
  double fish2X = 100; // 두 번째 어획물 X 좌표
  double fish3X = 150; // 세 번째 어획물 X 좌표

  bool moveRight1 = true; // 첫 번째 어획물 이동 방향
  bool moveRight2 = false; // 두 번째 어획물 이동 방향
  bool moveRight3 = true; // 세 번째 어획물 이동 방향

  double speed1 = 1.0; // 첫 번째 어획물 속도
  double speed2 = 1.5; // 두 번째 어획물 속도
  double speed3 = 1.2; // 세 번째 어획물 속도

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startFishMovement();
  }

  void _startFishMovement() {
    _timer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      setState(() {
        double screenWidth = MediaQuery.of(context).size.width;

        // 첫 번째 어획물 이동
        if (moveRight1) {
          fish1X += speed1;
          if (fish1X > screenWidth - 100)
            moveRight1 = false; // 오른쪽 벽에 닿으면 방향 변경
        } else {
          fish1X -= speed1;
          if (fish1X < 10) moveRight1 = true; // 왼쪽 벽에 닿으면 방향 변경
        }

        // 두 번째 어획물 이동
        if (moveRight2) {
          fish2X += speed2;
          if (fish2X > screenWidth - 100) moveRight2 = false;
        } else {
          fish2X -= speed2;
          if (fish2X < 10) moveRight2 = true;
        }

        // 세 번째 어획물 이동
        if (moveRight3) {
          fish3X += speed3;
          if (fish3X > screenWidth - 100) moveRight3 = false;
        } else {
          fish3X -= speed3;
          if (fish3X < 10) moveRight3 = true;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 30, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "조태공",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "이번달 누적 : n 마리",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "today",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    "1",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.favorite_border, color: Colors.red),
                  const SizedBox(width: 5),
                  Text(
                    "5",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(color: Colors.grey[400]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            "어항 가치 : 3,600,000원",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ),

        // 어획물 이동 애니메이션
        Expanded(
          child: Stack(
            children: [
              Positioned(
                left: fish1X,
                top: 100,
                child: Image.asset('assets/image/samchi.png', width: 80),
              ),
              Positioned(
                left: fish2X,
                top: 200,
                child: Image.asset('assets/image/moona.png', width: 90),
              ),
              Positioned(
                left: fish3X,
                bottom: 150,
                child: Image.asset('assets/image/gapojinga.png', width: 100),
              ),
            ],
          ),
        ),

        Center(
          child: Text(
            "더 많은...",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(child: Text("포인트페이지", style: TextStyle(fontSize: 30))),
      ),
    );
  }
}
