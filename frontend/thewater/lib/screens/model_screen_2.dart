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
      'assets/quantization_model.tflite',
    );
    List<List<List<double>>> imageArray = await convertFileToArray(file);
    List<List<double>> output = List.generate(1, (index) => List.filled(26, 0));
    interpreter.run([imageArray], output);
    List<double> model_result = output[0];
    print(model_result);
    int result_index = model_result.indexOf(
      model_result.reduce((a, b) => a > b ? a : b),
    );
    List fishList = [
      '감성돔',
      '벵에돔',
      '참돔',
      '복섬',
      '문어',
      '돌돔',
      '주꾸미',
      '성대',
      '문절망둑',
      '갑오징어',
      '노래미',
      '독가시치',
      '전갱이',
      '망상어',
      '고등어',
      '무늬오징어',
      '볼락',
      '광어',
      '우럭',
      '붕장어',
      '갈치',
      '양태',
      '숭어',
      '삼치',
      '학공치',
      '농어',
    ];
    setState(() {
      result = fishList[result_index]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('잡은 물고기 사진을 넣어주세요')),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // 이미지를 선택했다면 해당 이미지를 화면에 표시
              _image == null
                  ? SizedBox(height: 15,)
                  : Image.file(_image!), // 선택한 이미지를 화면에 표시

              SizedBox(height: 20),

              // 버튼들
              ElevatedButton(
                onPressed: _pickImageFromGallery,
                child: Text('갤러리에서 이미지 선택'),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImageFromCamera,
                child: Text('카메라로 사진 찍기'),
              ),
              _image == null ? SizedBox(height: 15,):
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: result, // 기본 텍스트
                      style: TextStyle(color: Colors.blue, fontSize: 36),
                    ),
                    TextSpan(
                      text: '를 잡았습니다 !!', // 기본 텍스트
                      style: TextStyle(color: Colors.black, fontSize: 36),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
