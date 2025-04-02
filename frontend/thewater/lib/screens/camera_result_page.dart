import 'package:flutter/material.dart';
import 'package:thewater/screens/model_screen_2.dart';
import 'dart:io';
import 'fish_card_screen.dart';

class CameraResultScreen extends StatelessWidget {
  final String imagePath;
  const CameraResultScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("잡은 물고기의 정체는?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ModelScreen2()),
              );
            },
            child: Text("모델 페이지로"),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80, left: 80, right: 80),
            child: Image.file(File(imagePath)),
          ),
          Text("35cm 놀래미를 잡았다!", style: TextStyle(fontSize: 30)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FishCardScreen()),
          );
        },
        child: Icon(Icons.add_circle_outline_rounded),
      ),
      // body: Container(child: Center(child: Text("result Page"))),
    );
  }
}
