import 'package:flutter/material.dart';

class GuestBookEntry {
  final String author;
  final String content;
  final DateTime date;

  GuestBookEntry({
    required this.author,
    required this.content,
    required this.date,
  });
}

class GuestBookModal extends StatefulWidget {
  final List<GuestBookEntry> entries;

  const GuestBookModal({Key? key, required this.entries}) : super(key: key);

  @override
  State<GuestBookModal> createState() => _GuestBookModalState();
}

class _GuestBookModalState extends State<GuestBookModal> {
  bool isLatestOrder = true; // true면 최신순, false면 오래된순

  @override
  Widget build(BuildContext context) {
    List<GuestBookEntry> sortedEntries = List.from(widget.entries);
    sortedEntries.sort((a, b) {
      if (isLatestOrder) {
        return b.date.compareTo(a.date);
      } else {
        return a.date.compareTo(b.date);
      }
    });

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
            "방명록",
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
                  "최신순",
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
                  "오래된순",
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
        // 나머지 방명록 리스트 영역...
        Expanded(
          child:
              sortedEntries.isEmpty
                  ? const Center(child: Text("아직 등록된 방명록이 없습니다"))
                  : ListView.builder(
                    itemCount: sortedEntries.length,
                    itemBuilder: (context, index) {
                      final entry = sortedEntries[index];
                      return Column(
                        children: [
                          ListTile(
                            title: Text(entry.author),
                            subtitle: Text(entry.content),
                            trailing: Text(
                              "${entry.date.year}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}",
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
