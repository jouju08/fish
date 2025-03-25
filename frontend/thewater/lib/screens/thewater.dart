import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:thewater/screens/camera_screen.dart';
import 'package:thewater/screens/login.dart';
import 'package:thewater/screens/model_screen.dart';
import 'package:thewater/screens/model_screen_2.dart';
import 'package:thewater/screens/fish_point.dart';

class TheWater extends StatefulWidget {
  const TheWater({super.key});

  @override
  State<TheWater> createState() => _TheWaterState();
}

class _TheWaterState extends State<TheWater> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Header"),
            ),
            ListTile(
              title: Text("물고기 판별하러 가기"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModelScreen()),
                );
              },
            ),
            ListTile(
              title: Text("모델 화면 2"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModelScreen2()),
                );
              },
            ),
            ListTile(
              title: Text("로그인하러 가기"),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: [const FirstPage(), const SecondPage()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CameraScreen()),
          );
        },
        child: const Icon(
          Icons.camera_alt,
          color: Color.fromRGBO(255, 255, 255, 1),
        ),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: ""),
        ],
      ),
    );
  }
}

class FirstPage extends StatelessWidget {
  const FirstPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: const mainPage(),
        ),
      ),
    );
  }
}

class mainPage extends StatefulWidget {
  const mainPage({Key? key}) : super(key: key);
  @override
  _mainPageState createState() => _mainPageState();
}

class _mainPageState extends State<mainPage> {
  // 위치 및 속도 변수
  double fish1X = 50, fish2X = 100, fish3X = 150;
  double fish1Y = 100, fish2Y = 200, fish3Y = 300;
  bool moveRight1 = true, moveRight2 = false, moveRight3 = true;
  double baseSpeed1 = 1.5, baseSpeed2 = 1.2, baseSpeed3 = 1.8;
  double speed1 = 1.5, speed2 = 1.2, speed3 = 1.8;
  double angle1 = 0, angle2 = 0, angle3 = 0;
  bool isPaused1 = false, isPaused2 = false, isPaused3 = false;
  late Timer _timer;
  double time = 0.0;

  @override
  void initState() {
    super.initState();
    _startFishMovement();
    _randomPauseForFish1();
    _randomPauseForFish2();
    _randomPauseForFish3();
  }

  void _startFishMovement() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        double screenWidth = MediaQuery.of(context).size.width;
        time += 0.05;

        // Y축 업데이트: 부드러운 파동 효과
        fish1Y = 100 + sin(time) * 20;
        fish2Y = 200 + sin(time + pi / 2) * 25;
        fish3Y = 300 + sin(time + pi) * 30;

        // X축 업데이트: 좌우 움직임 (멈추지 않은 경우에만)
        if (!isPaused1) {
          fish1X += moveRight1 ? speed1 : -speed1;
          angle1 = moveRight1 ? 0 : pi;
          if (fish1X > screenWidth - 100 || fish1X < 10) {
            moveRight1 = !moveRight1;
          }
        }
        if (!isPaused2) {
          fish2X += moveRight2 ? speed2 : -speed2;
          angle2 = moveRight2 ? 0 : pi;
          if (fish2X > screenWidth - 100 || fish2X < 10) {
            moveRight2 = !moveRight2;
          }
        }
        if (!isPaused3) {
          fish3X += moveRight3 ? speed3 : -speed3;
          angle3 = moveRight3 ? 0 : pi;
          if (fish3X > screenWidth - 100 || fish3X < 10) {
            moveRight3 = !moveRight3;
          }
        }
      });
    });
  }

  // 🐟 개별적으로 랜덤 멈추기 (원래 랜덤 멈춤 기능)
  void _randomPauseForFish1() {
    Timer.periodic(Duration(seconds: Random().nextInt(5) + 3), (timer) {
      _pauseSmoothly(1);
    });
  }

  void _randomPauseForFish2() {
    Timer.periodic(Duration(seconds: Random().nextInt(6) + 4), (timer) {
      _pauseSmoothly(2);
    });
  }

  void _randomPauseForFish3() {
    Timer.periodic(Duration(seconds: Random().nextInt(4) + 3), (timer) {
      _pauseSmoothly(3);
    });
  }

  // 🐟 부드럽게 멈추기: 감속 후 정지
  void _pauseSmoothly(int fishNumber) {
    double pauseDuration = Random().nextInt(3) + 1.0; // 1~3초 랜덤 멈춤
    double deceleration = 0.05;

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (fishNumber == 1) {
          if (speed1 > 0) {
            speed1 -= deceleration;
          } else {
            timer.cancel();
            Future.delayed(Duration(seconds: pauseDuration.toInt()), () {
              _resumeSmoothly(1);
            });
          }
        } else if (fishNumber == 2) {
          if (speed2 > 0) {
            speed2 -= deceleration;
          } else {
            timer.cancel();
            Future.delayed(Duration(seconds: pauseDuration.toInt()), () {
              _resumeSmoothly(2);
            });
          }
        } else if (fishNumber == 3) {
          if (speed3 > 0) {
            speed3 -= deceleration;
          } else {
            timer.cancel();
            Future.delayed(Duration(seconds: pauseDuration.toInt()), () {
              _resumeSmoothly(3);
            });
          }
        }
      });
    });
  }

  // 🐠 부드럽게 다시 이동: 가속하여 원래 속도로 복귀
  void _resumeSmoothly(int fishNumber) {
    double acceleration = 0.05;

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (fishNumber == 1) {
          if (speed1 < baseSpeed1) {
            speed1 += acceleration;
          } else {
            timer.cancel();
            moveRight1 = Random().nextBool();
          }
        } else if (fishNumber == 2) {
          if (speed2 < baseSpeed2) {
            speed2 += acceleration;
          } else {
            timer.cancel();
            moveRight2 = Random().nextBool();
          }
        } else if (fishNumber == 3) {
          if (speed3 < baseSpeed3) {
            speed3 += acceleration;
          } else {
            timer.cancel();
            moveRight3 = Random().nextBool();
          }
        }
      });
    });
  }

  // 🔥 터치하면 1초간 정지: 해당 물고기의 isPaused 플래그를 켜고 1초 후 해제
  void _pauseFishForOneSecond(int fishNumber) {
    setState(() {
      if (fishNumber == 1) {
        isPaused1 = true;
      } else if (fishNumber == 2) {
        isPaused2 = true;
      } else if (fishNumber == 3) {
        isPaused3 = true;
      }
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        if (fishNumber == 1) {
          isPaused1 = false;
        } else if (fishNumber == 2) {
          isPaused2 = false;
        } else if (fishNumber == 3) {
          isPaused3 = false;
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
      children: [
        // ✅ 상단 유저 정보 추가 ✅
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
                    child: const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "조태공",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "이번달 누적 : 8마리",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: const [
                  Text(
                    "today",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  SizedBox(width: 5),
                  Text(
                    "1",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Icon(Icons.favorite_border, color: Colors.red),
                  SizedBox(width: 5),
                  Text(
                    "5",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(color: Colors.grey),
        // ✅ 어항 가치 추가 ✅
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Center(
            child: Text(
              "어항 가치 : 3,600,000원",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              _buildFish(
                fish1X,
                fish1Y,
                angle1,
                'assets/image/samchi.png',
                80,
                1,
              ),
              _buildFish(
                fish2X,
                fish2Y,
                angle2,
                'assets/image/moona.png',
                90,
                2,
              ),
              _buildFish(
                fish3X,
                fish3Y,
                angle3,
                'assets/image/gapojinga.png',
                100,
                3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // _buildFish 함수 수정: 터치 시 _pauseFishForOneSecond() 호출
  Widget _buildFish(
    double x,
    double y,
    double angle,
    String imagePath,
    double size,
    int fishNumber,
  ) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: () {
          _pauseFishForOneSecond(fishNumber);
        },
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(angle),
          child: Image.asset(imagePath, width: size),
        ),
      ),
    );
  }
}
