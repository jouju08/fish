import 'package:flutter/material.dart';

class RankingEntry {
  final String author;
  final String introduce;
  final int price;

  RankingEntry({
    required this.author,
    required this.introduce,
    required this.price,
  });
}

class RankingModal extends StatefulWidget {
  final List<RankingEntry> entries;

  const RankingModal({Key? key, required this.entries}) : super(key: key);

  @override
  State<RankingModal> createState() => _GuestBookModalState();
}

class _GuestBookModalState extends State<RankingModal> {
  bool isLatestOrder = true; // true면 최신순, false면 오래된순

  @override
  Widget build(BuildContext context) {
    List<RankingEntry> sortedEntries = List.from(widget.entries);
    // sortedEntries.sort((a, b) {
    //   if (isLatestOrder) {
    //     return b.date.compareTo(a.date);
    //   } else {
    //     return a.date.compareTo(b.date);
    //   }
    // });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
          child: Text(
            "랭킹",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        // 버튼 영역
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.0),
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() => isLatestOrder = true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isLatestOrder ? Colors.blue : Colors.grey,
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "랭크",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() => isLatestOrder = false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: !isLatestOrder ? Colors.blue : Colors.grey,
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "둘러보기",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child:
              sortedEntries.isEmpty
                  ? const Center(child: Text("아직 등록된 랭킹이 없습니다"))
                  : ListView.builder(
                    itemCount: sortedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = sortedEntries[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(entry.author),
                            subtitle: Text(entry.introduce),
                            trailing: Text(
                              "${entry.price}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          const Divider(height: 1,thickness: 0.5,color: Colors.grey,), // 구분선
                        ],
                      );
                    },
                  ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
