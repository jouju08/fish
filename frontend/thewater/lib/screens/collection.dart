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
                    onTap: () => _showFishDetailModal(context, fishCard),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 물고기 이미지
                        Image.asset("assets/광어.jpg"),
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
                          "길이: ${fishCard["realSize"].toString()}cm",
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

  void _showFishDetailModal(
    BuildContext context,
    Map<String, dynamic> fishCard,
  ) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  fishCard["fishName"]!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Column(
                  children: [
                    Text("길이: ${fishCard["realSize"].toString()} cm"),
                    // 📝 여기에 추가할 내용 넣으면 됨!
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("닫기"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
