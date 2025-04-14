import 'package:flutter/material.dart';

void precacheFishImages(BuildContext context) {
  final List<String> imagePaths = [
    'assets/image/문어.gif',
    'assets/image/감성돔.gif',
    'assets/image/background.gif',
    'assets/image/낚시줄.png',
    'assets/image/문절망둑.gif',
    'assets/image/복섬.gif',
    'assets/image/광어.gif',
    'assets/image/볼락.gif',
    'assets/image/성대.gif',
    'assets/image/우럭.gif',
    'assets/image/농어.gif',
  ];

  for (var path in imagePaths) {
    precacheImage(AssetImage(path), context);
  }
}
