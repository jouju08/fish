import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/models/fish_provider.dart';
import 'package:thewater/providers/fish_provider.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key});

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  @override
  void initState() {
    debugPrint("collectionPage initState 실행됨");
    super.initState();
    Provider.of<FishModel>(context, listen: false).getFishCardList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("도감"), centerTitle: true),
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
            Text(
              "포획한 횟수 : ${Provider.of<FishModel>(context, listen: false).fishCardList.length}마리",
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
                  crossAxisCount: 3, // 한 줄에 3개
                  crossAxisSpacing: 10, // 가로 간격
                  mainAxisSpacing: 10, // 세로 간격
                  childAspectRatio: 0.7, // 카드(가로:세로) 비율 조정
                ),
                itemCount:
                    Provider.of<FishModel>(
                      context,
                      listen: true,
                    ).fishCardList.length,
                itemBuilder: (context, index) {
                  final fishCard =
                      Provider.of<FishModel>(
                        context,
                        listen: false,
                      ).fishCardList[index];
                  return GestureDetector(
                    onTap: () => _showFishDetailDialog(context, fishCard),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 물고기 이미지
                        Image.asset(
                          "assets/image/${fishCard["fishName"]}.png",
                          height: 100,
                        ),
                        const SizedBox(height: 8),
                        // 물고기 이름
                        Text(
                          fishCard["fishName"]!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "길이: ${fishCard["fishSize"].toString()}cm",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFishDetailDialog(
    BuildContext context,
    Map<String, dynamic> fishCard,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true, // 바깥 영역 탭하면 닫히도록 설정
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 둥근 모서리 적용
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  fishCard["fishName"]!,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 300,
                  height: 300,
                  child: FutureBuilder<Uint8List>(
                    future: Provider.of<FishModel>(
                      context,
                    ).fetchImageBytes(fishCard['cardImg']),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('에러 발생: ${snapshot.error}');
                      } else {
                        return Image.memory(snapshot.data!); // ← 바로 화면에 표시
                      }
                    },
                  ),
                ),
                Text("길이: ${fishCard["fishSize"]} cm"),
                Text("sky : ${fishCard["sky"]}"),
                Text("temperature : ${fishCard["temperature"]}"),
                Text("waterTemperature : ${fishCard["waterTemperature"]}"),
                Text("tide : ${fishCard["tide"]}"),
                Text("comment : ${fishCard["comment"]}"),
                Text("latitude : ${fishCard["latitude"]}"),
                Text("longitude : ${fishCard["longitude"]}"),
                Text("collectDate : ${fishCard["collectDate"]}"),
                TextButton(
                  onPressed: () {
                    Provider.of<FishModel>(
                      context,
                      listen: false,
                    ).deleteFishCard(context, fishCard['id']);
                  },
                  child: Text("삭제"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
