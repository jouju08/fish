import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class ModelScreen extends StatefulWidget {
  const ModelScreen({super.key});

  @override
  State<ModelScreen> createState() => _ModelScreenState();
}

class _ModelScreenState extends State<ModelScreen> {
  String result = "결과가 여기에 표시됩니다."; // 초기값
  // img.Image inputImage =

  Future<String> getAssetFilePath(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final tempDir = await getTemporaryDirectory();
    final tempPath = '${tempDir.path}/${basename(assetPath)}';
    final file = File(tempPath);
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return tempPath;
  }

  Future<List<List<List<double>>>> convertImageToArray(String assetPath) async {
    try {
      String imagePath = await getAssetFilePath(assetPath);
      // 이미지 파일 읽기
      print("imagePath: $imagePath");
      File imageFile = File(imagePath);
      Uint8List imageBytes = await imageFile.readAsBytes();

      // 이미지 디코딩
      img.Image? decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        throw Exception('이미지를 디코딩할 수 없습니다: $imagePath');
      }

      // 이미지 리사이징 (224x224)
      img.Image resizedImage = img.copyResize(
        decodedImage,
        width: 224,
        height: 224,
        interpolation: img.Interpolation.linear,
      );
      // inputImage = resizedImage;
      // 224x224x3 형태의 배열 생성
      List<List<List<double>>> imageArray = List.generate(
        224, // 높이
        (y) => List.generate(
          224, // 너비
          (x) {
            // 픽셀 값 가져오기
            int pixel = resizedImage.getPixel(x, y);

            // RGB 채널 분리 및 정규화 (0-1 범위로)
            return [
              img.getBlue(pixel) / 255.0, // B 채널
              img.getRed(pixel) / 255.0, // R 채널
              img.getGreen(pixel) / 255.0, // G 채널
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

  // modelrun() async {
  //   final interpreter = await Interpreter.fromAsset(
  //     'assets/model2_with_preprocessing.tflite',
  //   );

  //   // 이미지 바로 불러오기 (리사이징 및 정규화 필요 없음)
  //   String assetPath = 'assets/갑오징어.png';
  //   ByteData byteData = await rootBundle.load(assetPath);
  //   Uint8List bytes = byteData.buffer.asUint8List();

  //   // TensorImage로 바로 이미지 로드 (TensorFlow Lite Flutter Plugin 활용 권장)
  //   TensorImage tensorImage = TensorImage.fromFile(
  //     File(await getAssetFilePath(assetPath)),
  //   );

  //   // 입력 텐서 자동 구성 (모델에서 처리)
  //   var input = tensorImage.buffer;

  //   // 출력 배열 (클래스 수에 맞게)
  //   var output = List.filled(1 * 26, 0).reshape([1, 26]);

  //   interpreter.run(input, output);

  //   print(output);

  //   setState(() {
  //     result = output[0].toString();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("모델 페이지")),
      body: Center(
        child: Column(
          children: [
            Image(image: AssetImage('assets/갈치.png')),
            ElevatedButton(onPressed: () {}, child: Text("모델 실행하기")),
            Text(result, style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
