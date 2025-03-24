import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:thewater/screens/camera_screen.dart';
import 'package:thewater/screens/login.dart';
import 'package:thewater/screens/model_screen.dart';
import 'package:thewater/screens/model_screen_2.dart';

class TheWater extends StatefulWidget {
  final List<CameraDescription> cameras;
  const TheWater({Key? key, required this.cameras}) : super(key: key);

  @override
  State<TheWater> createState() => _TheWaterState();
}

class _TheWaterState extends State<TheWater> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Header"),
            ),
            ListTile(
              title: const Text("물고기 판별하러 가기"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ModelScreen()),
                );
              },
            ),
            ListTile(
              title: const Text("모델 화면 2"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ModelScreen2()),
                );
              },
            ),
            ListTile(title: const Text("view 3"), onTap: () {}),
          ],
        ),
      ),
      body: IndexedStack(
        index: currentIndex,
        children: const [FirstPage(), SecondPage()],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraScreen(cameras: widget.cameras),
            ),
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
      appBar: AppBar(
        title: const Text("로그인 화면 테스트"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const login()),
              );
            },
            icon: const Icon(Icons.navigation),
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer(); // 직접 Drawer 열기
            },
          ),
        ],
      ),
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
  // 기존 물고기 이동/정지 관련 변수들
  double fish1X = 50, fish2X = 100, fish3X = 150;
  double fish1Y = 100, fish2Y = 200, fish3Y = 300;
  bool moveRight1 = true, moveRight2 = false, moveRight3 = true;
  double baseSpeed1 = 1.5, baseSpeed2 = 1.2, baseSpeed3 = 1.8;
  double speed1 = 1.5, speed2 = 1.2, speed3 = 1.8;
  double angle1 = 0, angle2 = 0, angle3 = 0;
  bool isPaused1 = false, isPaused2 = false, isPaused3 = false;
  late Timer _timer;
  double time = 0.0;

  // "더 많은.." 버튼 토글
  bool showMoreMenu = false;

  @override
  void initState() {
    super.initState();
    _startFishMovement();
    _randomPauseForFish1();
    _randomPauseForFish2();
    _randomPauseForFish3();
  }

  // 물고기 이동 애니메이션
  void _startFishMovement() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        double screenWidth = MediaQuery.of(context).size.width;
        time += 0.05;

        // Y축 파동 이동
        fish1Y = 100 + sin(time) * 20;
        fish2Y = 200 + sin(time + pi / 2) * 25;
        fish3Y = 300 + sin(time + pi) * 30;

        // X축 좌우 이동
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

  // 각 물고기 랜덤 멈춤 처리
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

  // 부드러운 멈춤
  void _pauseSmoothly(int fishNumber) {
    double pauseDuration = Random().nextInt(3) + 1.0; // 1~3초 랜덤
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

  // 부드러운 재시작
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

  // 물고기 터치 시 1초간 정지
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

  // --- 위젯 빌드 ---
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1) 기존 UI는 Column으로
        Column(
          children: [
            // 상단 유저 정보
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
                            "이번달 누적 : n마리",
                            style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 0, 0, 0)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Text(
                        "today",
                        style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "n",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.favorite_border, color: Color.fromARGB(255, 14, 187, 255)),
                      SizedBox(width: 5),
                      Text(
                        "n",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // 2) "수족관 가치" & "더 많은.." 한 줄
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "수족관 가치 : 3,600,000원",
                    style: TextStyle(
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  // "더 많은.." 클릭 시 showMoreMenu 토글
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showMoreMenu = !showMoreMenu;
                      });
                    },
                    child: const Text(
                      "더 많은..",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3) 물고기들
            Expanded(
              child: Stack(
                children: [
                  _buildFish(fish1X, fish1Y, angle1, 'assets/image/samchi.png', 80, 1),
                  _buildFish(fish2X, fish2Y, angle2, 'assets/image/moona.png', 90, 2),
                  _buildFish(fish3X, fish3Y, angle3, 'assets/image/gapojinga.png', 100, 3),
                ],
              ),
            ),
          ],
        ),

        // 4) "더 많은.." 메뉴
        if (showMoreMenu)
          Positioned(
            top: 120,  // "수족관 가치" 아래 정도로 조정
            right: 16, // 화면 오른쪽 여백
            child: _buildMoreMenu(),
          ),
      ],
    );
  }

  // --- 물고기 위젯 ---
  Widget _buildFish(double x, double y, double angle, String imagePath, double size, int fishNumber) {
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

  // --- "더 많은.." 메뉴 위젯 ---
  Widget _buildMoreMenu() {
    // 아이콘 4개 세로 배치
    return Material(
      color: Colors.transparent, // 배경 투명
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildMenuIcon("어항", "assets/icon/어항.png"),
          _buildMenuIcon("도감", "assets/icon/도감.png"),
          _buildMenuIcon("방명록", "assets/icon/방명록.png"),
          _buildMenuIcon("랭킹", "assets/icon/랭킹.png"),
          _buildMenuIcon("공유", "assets/icon/카카오공유아이콘.png"),
        ],
      ),
    );
  }

  // --- 개별 메뉴 아이콘 ---
  Widget _buildMenuIcon(String label, String iconPath) {
    double iconSize = (label == "공유") ? 43 : 60;
    return GestureDetector(
      onTap: () {
        debugPrint("$label 메뉴 클릭");
        // TODO: 여기서 원하는 페이지 이동 or 기능 실행

        // 메뉴 닫기
        setState(() {
          showMoreMenu = false;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Image.asset(
            iconPath,
            width: iconSize,
            height: iconSize,
          ),
        ),
      ),
    );
  }
}

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/map_mock.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
