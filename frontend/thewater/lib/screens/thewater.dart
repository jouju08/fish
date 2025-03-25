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
        children: const [FirstPage(), SecondPage()],
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
      appBar: AppBar(
        title: const Text("로그인 화면 테스트"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
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

class _mainPageState extends State<mainPage> with TickerProviderStateMixin {
  // --- 물고기 이동/정지 관련 ---
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

  // --- Staggered Animations ---
  late AnimationController _menuController;
  // 아이콘 5개 → Slide/Fade 각각 5개
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  // 메뉴 아이템 (아이콘 + 라벨)
  final List<Map<String, String>> menuItems = [
    {"label": "어항", "icon": "assets/icon/어항.png"},
    {"label": "도감", "icon": "assets/icon/도감.png"},
    {"label": "방명록", "icon": "assets/icon/방명록.png"},
    {"label": "랭킹", "icon": "assets/icon/랭킹.png"},
    {"label": "공유", "icon": "assets/icon/카카오공유아이콘.png"},
  ];

  @override
  void initState() {
    super.initState();

    // 메뉴 애니메이션 초기화
    _initMenuAnimation();

    //물고기 이동 함수들
    _startFishMovement();
    _randomPauseForFish1();
    _randomPauseForFish2();
    _randomPauseForFish3();
  }

  // --- 물고기 이동 애니메이션 ---
  void _startFishMovement() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        final screenWidth = MediaQuery.of(context).size.width;
        time += 0.05;

        // Y축 파동 이동
        fish1Y = 100 + sin(time) * 20;
        fish2Y = 200 + sin(time + pi / 2) * 25;
        fish3Y = 300 + sin(time + pi) * 30;

        // X축 좌우 이동
        if (!isPaused1) {
          fish1X += moveRight1 ? speed1 : -speed1;
          angle1 = moveRight1 ? 0 : 3.14159; // pi
          if (fish1X > screenWidth - 100 || fish1X < 10) {
            moveRight1 = !moveRight1;
          }
        }
        if (!isPaused2) {
          fish2X += moveRight2 ? speed2 : -speed2;
          angle2 = moveRight2 ? 0 : 3.14159;
          if (fish2X > screenWidth - 100 || fish2X < 10) {
            moveRight2 = !moveRight2;
          }
        }
        if (!isPaused3) {
          fish3X += moveRight3 ? speed3 : -speed3;
          angle3 = moveRight3 ? 0 : 3.14159;
          if (fish3X > screenWidth - 100 || fish3X < 10) {
            moveRight3 = !moveRight3;
          }
        }
      });
    });
  }

  // --- Staggered Animation 초기화 ---
  void _initMenuAnimation() {
    // 메뉴 전체 재생 시간 (600ms)
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimations = [];
    _fadeAnimations = [];

    // 아이콘 5개 → 0~1 구간을 5등분 (각 아이콘이 조금씩 시간차를 두고)
    for (int i = 0; i < menuItems.length; i++) {
      // 예: 5개면 각 아이템은 0.0~0.8 / 0.2~1.0 이런 식
      double start = i * 0.15; // 0, 0.15, 0.3, 0.45, 0.6
      double end = start + 0.4; // 각 아이템은 0.4 구간 사용
      if (end > 1.0) end = 1.0;

      // Slide (위에서 아래로) → Offset(0, -0.2) ~ Offset(0, 0)
      final slideAnim = Tween<Offset>(
        begin: const Offset(0, -0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _menuController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

      // Fade (0 ~ 1)
      final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _menuController,
          curve: Interval(start, end, curve: Curves.easeIn),
        ),
      );

      _slideAnimations.add(slideAnim);
      _fadeAnimations.add(fadeAnim);
    }
  }

  // --- 물고기 랜덤 멈춤 ---
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

  // --- 부드러운 멈춤 ---
  void _pauseSmoothly(int fishNumber) {
    final pauseDuration = Random().nextInt(3) + 1.0;
    const deceleration = 0.05;

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

  // --- 부드러운 재시작 ---
  void _resumeSmoothly(int fishNumber) {
    const acceleration = 0.05;
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

  // --- 물고기 터치 시 1초간 정지 ---
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
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 1) 기존 UI: 상단 정보, 수족관 가치, 물고기들
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
                            style: TextStyle(fontSize: 14, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Text(
                        "today",
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                      SizedBox(width: 5),
                      Text(
                        "n",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.favorite_border, color: Colors.blue),
                      SizedBox(width: 5),
                      Text(
                        "n",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.grey),

            // 수족관 가치 & "더 많은.."
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "수족관 가치 : 3,600,000원",
                    style: TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showMoreMenu = !showMoreMenu;
                        if (showMoreMenu) {
                          _menuController.forward(); // 펼치기
                        } else {
                          _menuController.reverse(); // 닫기
                        }
                      });
                    },
                    child: const Text(
                      "더 많은..",
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 물고기 영역
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
        ),

        // 2) 펼쳐지는 메뉴 (Staggered Animations)
        // 만약 showMoreMenu가 false여도, 애니메이션 reverse 중일 수 있으므로 항상 배치
        Positioned(
          top: 120, // "수족관 가치" 아래 위치
          right: 16,
          child: IgnorePointer(
            // 아이콘을 클릭할 수 있는지 여부 → false면 애니메이션 reverse 중에도 터치 막기
            ignoring: !showMoreMenu,
            child: _buildStaggeredMenu(),
          ),
        ),
      ],
    );
  }

  // --- 물고기 위젯 ---
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

  // --- Staggered Menu (아이콘 여러 개) ---
  Widget _buildStaggeredMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(menuItems.length, (i) {
        return _buildStaggeredMenuItem(i);
      }),
    );
  }

  // --- 각 아이콘에 SlideTransition + FadeTransition 적용 ---
  Widget _buildStaggeredMenuItem(int index) {
    final label = menuItems[index]["label"]!;
    final iconPath = menuItems[index]["icon"]!;

    // 카카오 공유 아이콘만 작게 필터링
    double iconSize = (label == "공유") ? 43 : 60;

    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: GestureDetector(
          onTap: () {
            debugPrint("$label 메뉴 클릭");
            setState(() {
              showMoreMenu = false;
              _menuController.reverse();
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
              child: Image.asset(iconPath, width: iconSize, height: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}
