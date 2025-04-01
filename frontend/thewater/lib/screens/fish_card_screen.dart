import 'package:flutter/material.dart';
import 'package:thewater/models/fish_card.dart';

class FishCardScreen extends StatefulWidget {
  const FishCardScreen({super.key});

  @override
  _FishCardScreenState createState() => _FishCardScreenState();
}

class _FishCardScreenState extends State<FishCardScreen> {
  late Future<List<FishCard>> fishCards;

  @override
  void initState() {
    super.initState();
    // fishCards = ApiService.fetchFishCards();
    fishCards = Future.value([
      FishCard(
        cardId: 1,
        userId: 1,
        pointId: 1,
        fishId: 4,
        fishName: "놀래미",
        fishSize: 35,
        collectDate: "2025-03-20",
        sky: 5,
        tw: 1,
        tide: 2,
        comment: "와우",
        isDeleted: false,
        imgUrl: "imgUrl",
      ),
      FishCard(
        cardId: 2,
        userId: 1,
        pointId: 2,
        fishId: 5,
        fishName: "우럭",
        fishSize: 40,
        collectDate: "2025-03-18",
        sky: 3,
        tw: 2,
        tide: 1,
        comment: "맛있겠다",
        isDeleted: false,
        imgUrl: "imgUrl2",
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("물고기 카드 리스트")),
      body: FutureBuilder<List<FishCard>>(
        future: fishCards,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("데이터를 불러오는 데 실패했습니다."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("물고기 카드가 없습니다."));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                FishCard fish = snapshot.data![index];
                return Card(
                  child: ListTile(
                    // leading: Image.network(
                    //   fish.imgUrl,
                    //   width: 30,
                    //   height: 50,
                    //   fit: BoxFit.cover,
                    // ),
                    title: Text(fish.fishName),
                    subtitle: Text(
                      "크기: ${fish.fishSize}cm | 날짜: ${fish.collectDate}",
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
