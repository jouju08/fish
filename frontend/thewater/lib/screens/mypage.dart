import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/mypage_provider.dart';
import 'package:thewater/providers/user_provider.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({Key? key}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  Future<void> _showEditDialog({
    required String title,
    required String initialText,
    required Function(String newText) onSave,
  }) async {
    final controller = TextEditingController(text: initialText);
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("프로필 수정 - $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(labelText: title),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("취소"),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text("저장"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    // 화면 진입 후 마이페이지 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MypageProvider>(context, listen: false).getMyPage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mypageProvider = Provider.of<MypageProvider>(context);
    final userProvider = Provider.of<UserModel>(context, listen: false);

    final nickname =
        mypageProvider.nickname.isNotEmpty ? mypageProvider.nickname : "조태공";
    final comment =
        mypageProvider.comment.isNotEmpty
            ? mypageProvider.comment
            : "안녕하세요. 내 나이 스물여덟 낚시에 푹 빠져 삽니다";
    final cumulativeVisits = 2;
    final aquariumPublic = true;
    final latestFishDate =
        mypageProvider.latestFishDate.isNotEmpty
            ? mypageProvider.latestFishDate
            : "2025-04-08";
    final activityArea = "여수, 한강, 목포";

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/도감배경.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 10,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.logout, color: Colors.black),
                  onPressed: () {
                    userProvider.logout(context);
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  nickname,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 18,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    _showEditDialog(
                                      title: "닉네임 수정",
                                      initialText: nickname,
                                      onSave: (newText) async {
                                        bool success = await mypageProvider
                                            .updateNickname(newText);
                                        if (!success) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text("닉네임 수정 실패"),
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    Text(
                      comment,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("누적 방문수 $cumulativeVisits"),
                              Row(
                                children: [
                                  const Text("수족관 공개여부"),
                                  const SizedBox(width: 4),
                                  Icon(
                                    aquariumPublic
                                        ? Icons.lock_open
                                        : Icons.lock,
                                    size: 18,
                                    color: Colors.black,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "최근 출항일",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(latestFishDate),
                          const SizedBox(height: 12),
                          const Text(
                            "활동지역",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children:
                                activityArea.split(", ").map((area) {
                                  return Chip(
                                    label: Text(area),
                                    backgroundColor: Colors.blue.shade100,
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "마지막으로 잡은 물고기",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "가장 마지막으로 잡은 물고기 사진",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
