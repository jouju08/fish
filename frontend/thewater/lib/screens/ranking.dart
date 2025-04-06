import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/ranking_provider.dart';
import 'package:thewater/providers/search_provider.dart';

class RankingModal extends StatefulWidget {
  const RankingModal({super.key});

  @override
  State<RankingModal> createState() => _RankingModalState();
}

class _RankingModalState extends State<RankingModal> {
  bool isRandom = false;
  bool isSearching = false;
  String searchQuery = '';
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final rankingProvider = Provider.of<RankingProvider>(
      context,
      listen: false,
    );
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);

    rankingProvider.fetchTopRanking();
    searchProvider.fetchAllNicknames();
  }

  @override
  Widget build(BuildContext context) {
    final rankingProvider = Provider.of<RankingProvider>(context);
    final searchProvider = Provider.of<SearchProvider>(context);

    final List rankingList =
        isSearching
            ? searchProvider.searchResults
            : isRandom
            ? rankingProvider.randomRanking
            : rankingProvider.topRanking;

    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색창
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    hintText: '닉네임을 입력해주세요...',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  String keyword = _controller.text.trim();
                  if (keyword.isNotEmpty) {
                    await searchProvider.searchUsersByNickname(keyword);
                    setState(() {
                      isSearching = true;
                    });
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "주간 랭킹",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          Expanded(
            child:
                rankingList.isEmpty
                    ? const Center(child: Text("데이터가 없습니다."))
                    : ListView.separated(
                      itemCount: rankingList.length,
                      separatorBuilder:
                          (context, index) => const Divider(
                            color: Colors.grey,
                            thickness: 0.6,
                            indent: 10,
                            endIndent: 10,
                          ),
                      itemBuilder: (context, index) {
                        final item = rankingList[index];
                        final isSearchResult = isSearching;

                        final nickname =
                            isSearchResult ? item.nickname : item.nickname;
                        final comment =
                            isSearchResult
                                ? (item.comment ?? "한 줄 소개가 없습니다.")
                                : (item.memberComment ?? "한 줄 소개가 없습니다.");
                        final totalPrice =
                            isSearchResult ? null : item.totalPrice;

                        return ListTile(
                          leading: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          title: GestureDetector(
                            onTap: () {
                              int aquariumId =
                                  isSearchResult ? item.id : item.aquariumId;
                              debugPrint(
                                '유저 $nickname 의 어항으로 이동 (id: $aquariumId)',
                              );
                            },
                            child: Text(
                              nickname,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (totalPrice != null)
                                Text('어항 가치 : ₩${_formatPrice(totalPrice)}'),
                              Text(comment),
                            ],
                          ),
                        );
                      },
                    ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              icon: const Icon(Icons.cached, size: 30),
              onPressed: () async {
                setState(() {
                  isSearching = false;
                  isRandom = !isRandom;
                });

                if (isRandom) {
                  await rankingProvider.fetchRandomRanking();
                } else {
                  await rankingProvider.fetchTopRanking();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
