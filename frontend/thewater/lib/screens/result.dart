import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/fish_provider.dart';

class ResultScreen extends StatefulWidget {
  final File image;
  final String result;
  final double fishSize;

  const ResultScreen({
    super.key,
    required this.image,
    required this.result,
    required this.fishSize,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  List fishList = [
    '학공치',
    '문절망둑',
    '광어',
    '복섬',
    '문어',
    '주꾸미',
    '노래미',
    '무늬오징어',
    '농어',
    '갈치',
    '붕장어',
    '고등어',
    '독가시치',
    '감성돔',
    '삼치',
    '성대',
    '양태',
    '갑오징어',
    '전갱이',
    '망상어',
    '숭어',
    '볼락',
    '우럭',
    '돌돔',
    '벵에돔',
    '참돔',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(height: 20),
          SizedBox(
            width: 350,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0), // 내부 여백 조정
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 물고기 이미지
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                        ),

                        child: Image.file(widget.image, fit: BoxFit.contain),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 물고기 이름
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.result,
                          style: const TextStyle(
                            fontSize: 22, // 더 크게
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // IconButton(
                        //   onPressed: () {
                        //     showFishProbabilityDialog(context);
                        //   },
                        //   icon: Icon(
                        //     Icons.info_outline,
                        //     color: Colors.black54,
                        //     size: 20,
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 버튼 정렬 조정
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 150,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                  ),
                  child: Text(
                    "🔄 다시 찍기",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              if (widget.result != "찾을 수 없음")
                SizedBox(
                  width: 150, // 버튼 크기 조정
                  child: TextButton(
                    onPressed: () {
                      Provider.of<FishModel>(
                        context,
                        listen: false,
                      ).addFishCard(
                        widget.result,
                        widget.fishSize,
                        widget.image,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      "💾 저장",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
