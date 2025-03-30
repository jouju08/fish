import 'package:flutter/material.dart';

class FishSelectModal extends StatefulWidget {
  final void Function(String) onToggleFish;
  final Set<String> selectedFish;

  const FishSelectModal({
    Key? key,
    required this.onToggleFish,
    required this.selectedFish,
  }) : super(key: key);

  @override
  _FishSelectModalState createState() => _FishSelectModalState();
}

class _FishSelectModalState extends State<FishSelectModal> {
  final List<String> fishImages = [
    'assets/image/samchi.png',
    'assets/image/moona.gif',
    'assets/image/gapojinga.png',
    // 문어 등 추가 이미지 가능
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding:
          const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들바
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 12),
          // 물고기 리스트 (Wrap)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 10,
            children: fishImages.map((path) {
              bool isSelected = widget.selectedFish.contains(path);
              return GestureDetector(
                onTap: () {
                  widget.onToggleFish(path);
                  // 물고기를 탭하면 모달을 닫아서 메인 화면이 보이도록 함
                  Navigator.pop(context);
                },
                child: Container(
                  width: 90,
                  height: 90,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue
                          : const Color.fromARGB(255, 225, 225, 225),
                      width: 2,
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
