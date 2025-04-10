//auther: Jeong JuHa
//Date: 2025.04.09
//Description: 로딩 버블
import 'package:flutter/material.dart';
class LoadingBubble extends StatelessWidget {
  const LoadingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Text("..."),
      ),
    );
  }
}
