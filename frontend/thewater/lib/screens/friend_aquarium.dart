import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/aquarium_provider.dart';
import 'package:thewater/providers/user_provider.dart';
import 'package:thewater/providers/visit_provider.dart';
import 'fish_swimming.dart';

class FriendAquarium extends StatefulWidget {
  final int userId;
  final String nickname;
  const FriendAquarium({
    super.key,
    required this.userId,
    required this.nickname,
  });

  @override
  State<FriendAquarium> createState() => _FriendAquariumState();
}

class _FriendAquariumState extends State<FriendAquarium>
    with TickerProviderStateMixin {
  late FishSwimmingManager fishManager;
  bool fishManagerInitialized = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final aquariumModel = Provider.of<AquariumModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);

      // 친구 수족관 정보 가져오기
      await aquariumModel.fetchAquariumInfo(widget.userId);

      // 자신의 수족관이 아닐 경우만 친구 방문수 증가
      if (userModel.id != widget.userId) {
        final token = await userModel.token;
        if (token != null) {
          final visitApi = VisitApi();
          final success = await visitApi.visitAquarium(
            aquariumId: widget.userId, // 친구의 아쿠아리움 ID
            token: token,
          );
          if (success) {
            debugPrint("친구 수족관 방문 카운트 성공!");
          } else {
            debugPrint("친구 수족관 방문 카운트 실패!");
          }
        } else {
          debugPrint("토큰이 존재하지 않습니다.");
        }
      }

      fishManager = FishSwimmingManager(
        tickerProvider: this,
        context: context,
        update: () {
          if (mounted) setState(() {});
        },
      );
      fishManager.startFishMovement();

      final visibleFishList = aquariumModel.visibleFishCards;

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

  @override
  void dispose() {
    fishManager.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/background.gif'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
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
                              Consumer<AquariumModel>(
                                builder: (context, aquarium, _) {
                                  return Text(
                                    '수족관 가치 : ${_formatPrice(aquarium.totalPrice)}원',
                                    style: const TextStyle(fontSize: 15),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const Text("박문수", style: TextStyle(fontSize: 12)),
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
                                      await aquariumModel
                                          .toggleLikeFriendAquarium(
                                            widget.userId,
                                          );
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
              ],
            ),
            if (fishManagerInitialized) ...fishManager.buildFallingFishes(),
            if (fishManagerInitialized) ...fishManager.buildSwimmingFishes(),
            if (fishManagerInitialized) ...fishManager.buildRemovalAnimations(),
          ],
        ),
      ),
    );
  }
}
