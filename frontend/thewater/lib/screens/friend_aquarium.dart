import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/aquarium_provider.dart';
import 'package:thewater/providers/guestbook_provider.dart';
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
  final TextEditingController _guestBookController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final aquariumModel = Provider.of<AquariumModel>(context, listen: false);
      await aquariumModel.fetchAquariumInfo(widget.userId);

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
    _guestBookController.dispose();
    super.dispose();
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  void _showGuestBookModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, controller) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8),
                    child: Text(
                      "방명록",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(child: Center(child: Text('방명록 내용은 여기에 표시됩니다.'))),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _guestBookController,
                            decoration: InputDecoration(
                              hintText: '${widget.nickname} 님에게 방명록을 남겨보세요...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blue),
                          onPressed: () async {
                            if (_guestBookController.text.trim().isEmpty)
                              return;

                            // Provider 사용 context를 명확하게 넘겨줌
                            final success =
                                await Provider.of<GuestBookProvider>(
                                  context,
                                  listen: false,
                                ).writeGuestBook(
                                  widget.userId,
                                  _guestBookController.text,
                                );

                            if (success) {
                              _guestBookController.clear();
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
                  image: AssetImage('assets/image/background.png'),
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
                            child: Icon(Icons.person, size: 30),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.nickname,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Consumer<AquariumModel>(
                                builder:
                                    (_, aquarium, __) => Text(
                                      '수족관 가치 : ${_formatPrice(aquarium.totalPrice)}원',
                                      style: TextStyle(fontSize: 15),
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text("방문수", style: TextStyle(fontSize: 12)),
                          SizedBox(width: 5),
                          Consumer<AquariumModel>(
                            builder:
                                (_, aquariumModel, __) => Text(
                                  '${aquariumModel.visitCount}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                          ),
                          SizedBox(width: 10),
                          Consumer<AquariumModel>(
                            builder:
                                (_, aquariumModel, __) => Row(
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
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.grey),
              ],
            ),
            if (fishManagerInitialized) ...fishManager.buildFallingFishes(),
            if (fishManagerInitialized) ...fishManager.buildSwimmingFishes(),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showGuestBookModal(context),
                child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '${widget.nickname}님에게 방명록을 남겨보세요...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
