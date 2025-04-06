import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/aquarium_provider.dart';
import 'package:thewater/providers/fish_provider.dart';
import 'package:thewater/providers/user_provider.dart';
import 'package:thewater/screens/model_screen_2.dart';
import 'package:thewater/screens/fish_point.dart';
import 'package:thewater/screens/collection.dart';
import 'package:thewater/screens/fish_modal.dart';
import 'fish_swimming.dart';
import 'package:thewater/screens/guestbook.dart';
import 'package:thewater/screens/ranking.dart';
import 'package:thewater/screens/mypage.dart';

class TheWater extends StatefulWidget {
  final int pageIndex;
  const TheWater({super.key, required this.pageIndex});

  @override
  State<TheWater> createState() => _TheWaterState();
}

class _TheWaterState extends State<TheWater> {
  int bottomNavIndex = 0;
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
    pageIndex = widget.pageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userModel = Provider.of<UserModel>(context, listen: false);
      final aquariumModel = Provider.of<AquariumModel>(context, listen: false);
      // 사용자 정보 가져오고 기다림
      await userModel.fetchUserInfo();

      // user id 확인 후 수족관정보 가져오는거에 userid 대입해서 가져오는거
      if (userModel.id != 0) {
        await aquariumModel.fetchAquariumInfo(userModel.id);
        debugPrint("수족관 정보 불러오기 성공, userId : ${userModel.id}");
      } else {
        debugPrint("사용자 id가 아직 0입니다.");
      }
    });
  }

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
                child: Text("그물", style: TextStyle(fontSize: 30)),
              ),
              ListTile(
                title: const Text("회원가입"),
                onTap: () {
                  Navigator.pushNamed(context, '/signup');
                },
              ),
              ListTile(
                title: const Text("로그인"),
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              ListTile(
                title: const Text("로그아웃"),
                onTap: () {
                  Provider.of<UserModel>(context, listen: false).logout();
                  Navigator.pushNamed(context, '/');
                },
              ),
              ListTile(
                title: const Text("물고기 판별"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ModelScreen2(),
                    ),
                  );
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
  List<GuestBookEntry> guestBookEntries = [
    // 방명로끄 목업데이터
    GuestBookEntry(
      author: '킹수정',
      content: '어이어이 나 왔다 간다구~~~',
      date: DateTime.now(),
    ),
    GuestBookEntry(
      author: '황치치',
      content: '보라색 점프홀더 깨면 커피',
      date: DateTime.utc(2024, 01, 22),
    ),
    GuestBookEntry(
      author: '킹주헌',
      content: '다이어트 작심삼일',
      date: DateTime.utc(2011, 06, 23),
    ),
    GuestBookEntry(
      author: '홍재민',
      content: '헤응!',
      date: DateTime.utc(1998, 10, 06),
    ),
  ];

  final List<Map<String, String>> menuItems = [
    {"label": "어항", "icon": "assets/icon/어항.png"},
    {"label": "도감", "icon": "assets/icon/도감.png"},
    {"label": "방명록", "icon": "assets/icon/방명록.png"},
    {"label": "랭킹", "icon": "assets/icon/랭킹.png"},
    {"label": "공유", "icon": "assets/icon/카카오공유아이콘.png"},
  ];

  // 수족관에 추가된 물고기 imagePath를 저장하는 집합
  Set<String> _selectedFish = {};

  @override
  void initState() {
    super.initState();
    _initMenuAnimation();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final fishModel = Provider.of<FishModel>(context, listen: false);
      await fishModel.getFishCardList();

      fishManager = FishSwimmingManager(
        tickerProvider: this,
        context: context,
        update: () {
          if (mounted) setState(() {});
        },
      );
      fishManager.startFishMovement();

      final visibleFishList =
          fishModel.fishCardList
              .where((fish) => fish["hasVisible"] == true)
              .toList();

      setState(() {
        fishManagerInitialized = true;
      });

      for (var fish in visibleFishList) {
        var fishName = fish["fishName"];
        var path = "assets/image/$fishName.png";
        fishManager.addFallingFish(path, fishName);

        await Future.delayed(const Duration(milliseconds: 500));
      }
    });
  }

  //Provider.of<CounterProvider>(context).count

  void _openGuestBookModal() {
    final double topOffset = 200;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: screenHeight - topOffset,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GuestBookModal(entries: guestBookEntries),
          ),
        );
      },
    );
  }

  void _openRankingModal() {
    final double topOffset = 200;
    final screenHeight = MediaQuery.of(context).size.height;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: screenHeight - topOffset,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: RankingModal(),
        );
      },
    );
  }

  void _openFishSelectModal() async {
    final fishModel = Provider.of<FishModel>(context, listen: false);

    // 최신 서버 데이터 가져오기 (중요!)
    await fishModel.getFishCardList();
    final fishCardList = fishModel.fishCardList;

    final fishDataList =
        fishCardList
            .map(
              (card) => {
                "id": card["id"],
                "fishName": card["fishName"],
                "hasVisible": card["hasVisible"] ?? false,
              },
            )
            .toList();

    final fishImages =
        fishDataList
            .map((data) => "assets/image/${data["fishName"]}.png")
            .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => FishSelectModal(
            fishDataList: fishDataList,
            fishImages: fishImages,
            selectedFish:
                fishDataList
                    .where((fish) => fish["hasVisible"])
                    .map((fish) => "assets/image/${fish["fishName"]}.png")
                    .toSet(),
            onToggleFish: (
              String path,
              int fishId,
              bool currentHasVisible,
            ) async {
              setState(() {
                if (currentHasVisible) {
                  fishManager.removeFishWithFishingLine(path);
                  _selectedFish.remove(path);
                } else {
                  String fishName = path.split('/').last.split('.').first;
                  fishManager.addFallingFish(path, fishName);
                  _selectedFish.add(path);
                }
                debugPrint("선택된 물고기 목록 : $_selectedFish");
                fishModel.toggleFishVisibility(fishId);
              });
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
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MyPageScreen(),
                                ),
                              );
                            },
                            child: Text(
                              Provider.of<UserModel>(context).nickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            "이번달 누적 : ${Provider.of<FishModel>(context).fishCardList.length}마리",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text("today", style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 5),
                      Consumer<AquariumModel>(
                        builder: (context, aquariumModel, child) {
                          return Text(
                            '${aquariumModel.visitCount}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 10),

                      /// 좋아요 로직
                      Consumer<AquariumModel>(
                        builder: (context, aquariumModel, child) {
                          return Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  aquariumModel.likedByMe
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color:
                                      aquariumModel.likedByMe
                                          ? Colors.blue
                                          : Colors.grey,
                                ),
                                onPressed: () async {
                                  await aquariumModel.toggleLikeAquarium();
                                },
                              ),
                              Text(
                                '${aquariumModel.likeCount}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          );
                        },
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
        if (fishManagerInitialized) ...fishManager.buildFallingFishes(),
        if (fishManagerInitialized) ...fishManager.buildSwimmingFishes(),
        if (fishManagerInitialized) ...fishManager.buildRemovalAnimations(),

        if (showMoreMenu)
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  showMoreMenu = false;
                  _menuController.reverse();
                });
              },
              child: Container(color: Colors.transparent),
            ),
          ),

        Positioned(
          top: 120,
          right: 16,
          child: IgnorePointer(
            ignoring: !showMoreMenu,
            child: _buildStaggeredMenu(),
          ),
        ),
        // 물고기 애니메이션 위젯들
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
            if (label == "방명록") {
              _openGuestBookModal();
            }
            if (label == "랭킹") {
              _openRankingModal();
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
