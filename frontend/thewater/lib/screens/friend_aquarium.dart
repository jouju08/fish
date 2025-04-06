import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/aquarium_provider.dart';

class FriendsAquariumScreen extends StatefulWidget {
  final int userId;
  final String nickname;

  const FriendsAquariumScreen({
    super.key,
    required this.userId,
    required this.nickname,
  });

  @override
  State<FriendsAquariumScreen> createState() => _FriendsAquariumScreenState();
}

class _FriendsAquariumScreenState extends State<FriendsAquariumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final aquariumModel = Provider.of<AquariumModel>(context, listen: false);
      await aquariumModel.fetchAquariumInfo(widget.userId);
    });
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.nickname}의 수족관")),
      body: Consumer<AquariumModel>(
        builder: (context, aquariumModel, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
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
                            Text(
                              widget.nickname,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "누적 방문수 : ${aquariumModel.visitCount}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text("좋아요", style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 5),
                        Icon(
                          Icons.favorite,
                          color:
                              aquariumModel.likedByMe
                                  ? Colors.blue
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${aquariumModel.likeCount}',
                          style: const TextStyle(
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "수족관 가치 : ₩${_formatPrice(aquariumModel.totalPrice)}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
              const Divider(color: Colors.grey),
              // TODO: 여기에 물고기/애니메이션 등 thewater와 같은 기능 추가 가능
            ],
          );
        },
      ),
    );
  }
}
