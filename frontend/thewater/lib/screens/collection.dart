import 'package:flutter/material.dart';

class CollectionPage extends StatelessWidget {
  const CollectionPage({Key? key}) : super(key: key);

  // 예시용 임시 데이터 (나중에 백엔드 연동 시 변경)
  static const List<Map<String, String>> fishData = [
    {"name": "갈치", "image": "assets/갈치.png"},
    {"name": "광어", "image": "assets/광어.jpg"},
    {"name": "감성돔", "image": "assets/감성돔.png"},
    {"name": "갑오징어", "image": "assets/갑오징어.png"},
    {"name": "갈치", "image": "assets/갈치.png"},
    {"name": "광어", "image": "assets/광어.jpg"},
    {"name": "감성돔", "image": "assets/감성돔.png"},
    {"name": "갑오징어", "image": "assets/갑오징어.png"},
    {"name": "갈치", "image": "assets/갈치.png"},
    {"name": "광어", "image": "assets/광어.jpg"},
    {"name": "감성돔", "image": "assets/감성돔.png"},
    {"name": "갑오징어", "image": "assets/갑오징어.png"},
    {"name": "갈치", "image": "assets/갈치.png"},
    {"name": "광어", "image": "assets/광어.jpg"},
    {"name": "감성돔", "image": "assets/감성돔.png"},
    {"name": "갑오징어", "image": "assets/갑오징어.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 AppBar
      appBar: AppBar(
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pushNamed(context,'/');
        //   },
        //   ),
        title: const Text("도감"),
        centerTitle: true,
      ),

      // 배경 설정
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/도감배경.png'), // 도감 배경
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // 상단에 이번달 포획한 횟수 표시
            const SizedBox(height: 16),
            const Text(
              "이번달 포획한 횟수 : n마리",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 물고기 목록을 3열(Grid)로 표시
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                // 3열 배치
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,        // 한 줄에 3개
                  crossAxisSpacing: 10,     // 가로 간격
                  mainAxisSpacing: 10,      // 세로 간격
                  childAspectRatio: 0.7,    // 카드(가로:세로) 비율 조정
                ),
                itemCount: fishData.length,
                itemBuilder: (context, index) {
                  final fish = fishData[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        // 물고기 이미지
                        child: Image.asset(
                          fish["image"]!,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // 물고기 이름
                      Text(
                        fish["name"]!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
