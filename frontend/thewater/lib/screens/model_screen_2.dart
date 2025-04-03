import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ModelScreen2 extends StatefulWidget {
  const ModelScreen2({super.key});

  @override
  State<ModelScreen2> createState() => _ModelScreen2State();
}

class _ModelScreen2State extends State<ModelScreen2> {
  File? _image;
  String result = "";
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImageFromGallery() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      modelrun(File(pickedFile.path));
      setState(() {
        _image = File(pickedFile.path); // 선택한 이미지 파일 저장
      });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedFile != null) {
      modelrun(File(pickedFile.path));
      setState(() {
        _image = File(pickedFile.path); // 촬영한 이미지 파일 저장
      });
    }
  }

  Future<List<List<List<double>>>> convertFileToArray(File file) async {
    try {
      Uint8List imageBytes = await file.readAsBytes();

      img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        throw Exception('이미지를 디코딩할 수 없습니다');
      }

      // 이미지 리사이징 (224x224)
      img.Image resizedImage = img.copyResize(
        decodedImage,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.linear,
      );

      // 224x224x3 형태의 배열 생성
      List<List<List<double>>> imageArray = List.generate(
        224, // 높이
        (y) => List.generate(
          224, // 너비
          (x) {
            // 픽셀 값 가져오기
            int pixel = resizedImage.getPixel(x, y);

            return [
              img.getBlue(pixel).toDouble(),
              img.getGreen(pixel).toDouble(),
              img.getRed(pixel).toDouble(),
            ];
          },
        ),
      );

      return imageArray;
    } catch (e) {
      print('이미지 변환 중 오류 발생: $e');
      rethrow;
    }
  }

  modelrun(File file) async {
    final interpreter = await Interpreter.fromAsset(
      'assets/QAT_50model_mixed.tflite',
    );
    List<List<List<double>>> imageArray = await convertFileToArray(file);
    List<List<double>> output = List.generate(1, (index) => List.filled(26, 0));
    interpreter.run([imageArray], output);
    List<double> modelResult = output[0];
    print(modelResult);
    int resultIndex = modelResult.indexOf(
      modelResult.reduce((a, b) => a > b ? a : b),
    );
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
    setState(() {
      result = fishList[resultIndex]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('물고기 사진을 넣어주세요')),
      body:
          _image == null
              ? Column(
                mainAxisAlignment: MainAxisAlignment.center, // 중앙 정렬
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 갤러리 선택 버튼
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ElevatedButton(
                          onPressed: _pickImageFromGallery,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo, size: 40, color: Colors.black),
                              SizedBox(height: 8),
                              Text(
                                '갤러리',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 20), // 버튼 간격 조정
                      // 카메라 버튼
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: ElevatedButton(
                          onPressed: _pickImageFromCamera,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt,
                                size: 40,
                                color: Colors.black,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '카메라',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: Image.file(_image!, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // 물고기 이름
                            Text(
                              result,
                              style: const TextStyle(
                                fontSize: 22, // 더 크게
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // 물고기 크기
                            Text(
                              "크기: 10cm",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
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
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _image = null; // 이미지 초기화
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 30,
                            ),
                          ),
                          child: Text("🔄 다시 찍기"),
                        ),
                      ),
                      SizedBox(
                        width: 150, // 버튼 크기 조정
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text("💾 저장"),
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
