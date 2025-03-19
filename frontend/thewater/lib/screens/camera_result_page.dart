import 'package:flutter/material.dart';
import 'dart:io';

class CameraResultPage extends StatelessWidget {
  final String imagePath;
  const CameraResultPage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("result Page")),
      body: Image.file(File(imagePath)),
      // body: Container(child: Center(child: Text("result Page"))),
    );
  }
}
