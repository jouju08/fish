import 'package:flutter/material.dart';
import 'package:thewater/screens/model_screen_2.dart';
import 'package:thewater/screens/fish_point.dart';
import 'package:thewater/screens/collection.dart';
import 'package:thewater/screens/fish_modal.dart';
import 'fish_swimming.dart';
import 'model_segment_screen.dart';

class TheWater extends StatefulWidget {
  const TheWater({super.key});

  @override
  State<TheWater> createState() => _TheWaterState();
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
                      builder: (context) => const ModelScreen2(),
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
                title: const Text("모델 화면 3, 거리 계산"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModelSegmentScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                title: const Text("로그인하러 가기"),
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
              MaterialPageRoute(builder: (context) => ModelScreen2()),
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
          child: const MainPage(),
        ),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late FishSwimmingManager fishManager;
  bool fishManagerInitialized = false;
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

  @override
  void initState() {
    super.initState();
    _initMenuAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fishManager = FishSwimmingManager(
        tickerProvider: this,
        context: context,
        update: () {
          if (mounted) setState(() {});
        },
      );
      fishManager.startFishMovement();
      setState(() {
        fishManagerInitialized = true;
      });
    });
  }

  void _openFishSelectModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => FishSelectModal(
            onFishSelected: (imagePath) {
              fishManager.addFallingFish(imagePath);
            },
          ),
    );
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

  @override
  void dispose() {
    fishManager.dispose();
    _menuController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 상단 UI: 유저 정보, 수족관 가치 등
        Column(
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
        // 물고기 애니메이션 위젯들
        if (fishManagerInitialized) ...fishManager.buildFallingFishes(),
        if (fishManagerInitialized) ...fishManager.buildSwimmingFishes(),
      ],
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
