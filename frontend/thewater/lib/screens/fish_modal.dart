import 'package:flutter/material.dart';

class FishSelectModal extends StatelessWidget {
  final void Function(String) onFishSelected;

  FishSelectModal({super.key, required this.onFishSelected});

  final List<String> fishImages = [
    'assets/image/samchi.png',
    'assets/image/moona.png',
    'assets/image/gapojinga.png',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 👉 핸들바
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12), // 핸들과 콘텐츠 사이 간격
          // 👉 물고기 리스트
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 10,
            children:
                fishImages.map((path) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onFishSelected(path);
                    },
                    child: Container(
                      width: 90,
                      height: 90,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromARGB(255, 225, 225, 225),
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Image.asset(path),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class FallingFish {
  final String imagePath;
  double top;
  bool landed;

  FallingFish({required this.imagePath, this.top = -100, this.landed = false});
}
