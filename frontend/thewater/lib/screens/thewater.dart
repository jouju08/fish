import 'dart:async';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:thewater/screens/camera_screen.dart';
import 'package:thewater/screens/login.dart';
import 'package:thewater/screens/model_screen.dart';
import 'package:thewater/screens/model_screen_2.dart';
import 'package:thewater/screens/fish_point.dart';
import 'package:thewater/screens/collection.dart';

class TheWater extends StatefulWidget {
  const TheWater({super.key});

  @override
  State<TheWater> createState() => _TheWaterState();
}

class SwimmingFish {
  final String imagePath;
  double x;
  double y;
  bool moveRight;
  double speed;
  double angle;

  SwimmingFish({
    required this.imagePath,
    required this.x,
    required this.y,
    this.moveRight = true,
    this.speed = 1.5,
    this.angle = 0,
  });
}

class _TheWaterState extends State<TheWater> {
  int bottomNavIndex = 0;
  int pageIndex = 0;

  void onBottomNavTap(int newIndex) {
    setState(() {
      bottomNavIndex = newIndex;
      pageIndex = newIndex;
    });
  }

  void showCollectionPage() {
    // 도감 탭
    setState(() {
      pageIndex = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (pageIndex != 0) {
          setState(() {
            pageIndex = 0;
            bottomNavIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                    MaterialPageRoute(
                      builder: (context) => const ModelScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text("모델 화면 2"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModelScreen2(),
                    ),
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
          index: pageIndex,
          children: const [FirstPage(), SecondPage(), CollectionPage()],
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
          currentIndex: bottomNavIndex,
          onTap: onBottomNavTap,
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

class FallingFish {
  final String imagePath;
  double top;
  bool landed;

  FallingFish({required this.imagePath, this.top = -100, this.landed = false});
}

class _mainPageState extends State<mainPage> with TickerProviderStateMixin {
  // --- 물고기 이동/정지 관련 ---
  List<SwimmingFish> swimmingFishes = [];
  double fish1X = 50;
  double fish1Y = 100;
  bool moveRight1 = true;
  double baseSpeed1 = 1.5;
  double speed1 = 1.5;
  double angle1 = 0;
  bool isPaused1 = false;
  late Timer _timer;
  double time = 0.0;

  bool showMoreMenu = false;

  late AnimationController _menuController;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _fadeAnimations;

  final List<Map<String, String>> menuItems = [
    {"label": "어항", "icon": "assets/icon/어항.png"},
    {"label": "도감", "icon": "assets/icon/도감.png"},
    {"label": "방명록", "icon": "assets/icon/방명록.png"},
    {"label": "랭킹", "icon": "assets/icon/랭킹.png"},
    {"label": "공유", "icon": "assets/icon/카카오공유아이콘.png"},
  ];

  List<FallingFish> fallingFishes = [];

  @override
  void initState() {
    super.initState();
    _initMenuAnimation();
    _startFishMovement();
    _randomPauseForFish1();
  }

  void _startFishMovement() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        final screenWidth = MediaQuery.of(context).size.width;
        time += 0.05;

        // Y축 파동 이동
        fish1Y = 100 + sin(time) * 20;

        // X축 이동
        if (!isPaused1) {
          fish1X += moveRight1 ? speed1 : -speed1;
          angle1 = moveRight1 ? 0 : 3.14159;
          if (fish1X > screenWidth - 100 || fish1X < 10) {
            moveRight1 = !moveRight1;
          }
        }

        for (var fish in swimmingFishes) {
          // 테스트코드 확인후 지우길바람
          fish.y += sin(time) * 0.5;
          fish.x += fish.moveRight ? fish.speed : -fish.speed;
          fish.angle = fish.moveRight ? 0 : 3.14159;

          if (fish.x > screenWidth - 80 || fish.x < 10) {
            fish.moveRight = !fish.moveRight;
          }
        }
      });
    });
  }

  void _openFishSelectModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => FishSelectModal(onFishSelected: _addFallingFish),
    );
  }

  void _addFallingFish(String imagePath) {
    final newFish = FallingFish(imagePath: imagePath);
    fallingFishes.add(newFish);
    _animateFishFall(newFish);
  }

  void _animateFishFall(FallingFish fish) {
    const double targetY = 400;
    const double baseSpeed = 20;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        double progress = (fish.top / targetY).clamp(0.0, 1.0);
        double currentSpeed = baseSpeed * (1 - progress); // 감속
        if (fish.top <= targetY - 2) {
          // 떨어지는 값 맞춤 수영로직 연결 조건
          fish.top += currentSpeed;
        } else {
          fish.landed = true;
          timer.cancel();

          final random = Random();
          swimmingFishes.add(
            SwimmingFish(
              imagePath: fish.imagePath,
              x: MediaQuery.of(context).size.width / 2 - 40,
              y: fish.top,
              moveRight: random.nextBool(),
              speed: 1.2 + random.nextDouble(),
            ),
          );
          fallingFishes.remove(fish);
        }
      });
    });
  }

  List<Widget> _buildSwimmingFishes() {
    return swimmingFishes.map((fish) {
      return Positioned(
        top: fish.y,
        left: fish.x,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(fish.angle),
          child: Image.asset(fish.imagePath, width: 80),
        ),
      );
    }).toList();
  }

  List<Widget> _buildFallingFishes() {
    return fallingFishes.map((fish) {
      return Positioned(
        top: fish.top,
        left: MediaQuery.of(context).size.width / 2 - 40,
        child: Image.asset(fish.imagePath, width: 80),
      );
    }).toList();
  }

  void _initMenuAnimation() {
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnimations = [];
    _fadeAnimations = [];

    for (int i = 0; i < menuItems.length; i++) {
      double start = i * 0.15;
      double end = (start + 0.4).clamp(0.0, 1.0);

      final slideAnim = Tween<Offset>(
        begin: const Offset(0, -0.2),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _menuController,
          curve: Interval(start, end, curve: Curves.easeOut),
        ),
      );

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

  void _randomPauseForFish1() {
    Timer.periodic(Duration(seconds: Random().nextInt(5) + 3), (timer) {
      _pauseSmoothly();
    });
  }

  void _pauseSmoothly() {
    final pauseDuration = Random().nextInt(3) + 1;
    const deceleration = 0.05;

    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (speed1 > 0) {
          speed1 -= deceleration;
        } else {
          timer.cancel();
          Future.delayed(Duration(seconds: pauseDuration), () {
            _resumeSmoothly();
          });
        }
      });
    });
  }

  void _resumeSmoothly() {
    const acceleration = 0.05;
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (speed1 < baseSpeed1) {
          speed1 += acceleration;
        } else {
          timer.cancel();
          moveRight1 = Random().nextBool();
        }
      });
    });
  }

  void _pauseFishForOneSecond() {
    setState(() {
      isPaused1 = true;
    });
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isPaused1 = false;
      });
    });
  }

  // void _openFishSelectModal() {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (_) => const FishSelectModal(onFishSelect)
  //     )
  // }

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
        Column(
          children: [
            // 유저 정보 및 상단 UI
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
                        child: const Icon(Icons.person, size: 30),
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
                          Text("이번달 누적 : n마리", style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: const [
                      Text("today", style: TextStyle(fontSize: 12)),
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

            // 수족관 가치 + "더 많은.."
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "수족관 가치 : 3,600,000원",
                    style: TextStyle(fontSize: 18),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showMoreMenu = !showMoreMenu;
                        if (showMoreMenu) {
                          _menuController.forward();
                        } else {
                          _menuController.reverse();
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
                  ),
                ],
              ),
            ),
          ],
        ),

        // 펼쳐지는 메뉴
        Positioned(
          top: 120,
          right: 16,
          child: IgnorePointer(
            ignoring: !showMoreMenu,
            child: _buildStaggeredMenu(),
          ),
        ),
        ..._buildFallingFishes(),
        ..._buildSwimmingFishes(),
      ],
    );
  }

  Widget _buildFish(
    double x,
    double y,
    double angle,
    String imagePath,
    double size,
  ) {
    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onTap: _pauseFishForOneSecond,
        child: Transform(
          alignment: Alignment.center,
          transform: Matrix4.rotationY(angle),
          child: Image.asset(imagePath, width: size),
        ),
      ),
    );
  }

  Widget _buildStaggeredMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(menuItems.length, (i) {
        return _buildStaggeredMenuItem(i);
      }),
    );
  }

  Widget _buildStaggeredMenuItem(int index) {
    final label = menuItems[index]["label"]!;
    final iconPath = menuItems[index]["icon"]!;
    double iconSize = (label == "공유") ? 43 : 60;

    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: GestureDetector(
          onTap: () {
            if (label == "도감") {
              final parentState =
                  context.findAncestorStateOfType<_TheWaterState>();
              parentState?.showCollectionPage();
            }
            if (label == "어항") {
              _openFishSelectModal();
            }

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

class FishSelectModal extends StatelessWidget {
  final void Function(String) onFishSelected;

  FishSelectModal({Key? key, required this.onFishSelected}) : super(key: key);

  final List<String> fishImages = [
    'assets/image/samchi.png',
    'assets/image/moona.png',
    'assets/image/gapojinga.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 👉 핸들바
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12), // 핸들과 콘텐츠 사이 간격
          // 👉 물고기 리스트
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 10,
            children:
                fishImages.map((path) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onFishSelected(path);
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 225, 225, 225),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(path),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}
