import 'dart:io'; // 파일을 다루기 위해 import
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart'; // 파일 경로 처리
import 'package:thewater/screens/camera_result_page.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller; // 카메라 컨트롤러
  bool _isCameraInitialized = false;
  String _imagePath = ''; // 초기값으로 빈 문자열 할당

  @override
  void initState() {
    super.initState();
    _initializeCamera(); // 카메라 초기화
  }

  // 카메라 초기화 함수
  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras(); // 사용 가능한 카메라 가져오기
      if (cameras.isEmpty) {
        debugPrint("카메라를 찾을 수 없습니다.");
        return;
      }

      _controller = CameraController(
        cameras[0], // 후면 카메라 사용
        ResolutionPreset.high,
      );

      await _controller.initialize();
      await _controller.setFlashMode(FlashMode.off); // 플래시 끄기
      setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint("카메라 초기화 오류: $e");
    }
  }

  // 사진 찍기
  Future<void> _takePicture() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = join(
        directory.path,
        '${DateTime.now().millisecondsSinceEpoch}.png',
      ); // 파일명 생성
      final XFile file = await _controller.takePicture();
      final File imageFile = File(imagePath);
      await file.saveTo(imageFile.path); // XFile을 File로 변환하여 저장
      setState(() {
        _imagePath = imagePath; // 저장된 이미지 경로
      });
    } catch (e) {
      _showErrorDialog('사진을 찍을 수 없습니다.');
    }
  }

  // 오류 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: this.context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // 카메라 리소스 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // 초기화가 안되었을 때 로딩 화면
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text('물고기를 찍어주세요!', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[700],
      ),
      backgroundColor: Colors.grey[600],
      body: Column(
        children: [
          Center(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CameraPreview(_controller),
                ), // 카메라 미리보기
                Image(image: AssetImage('assets/image/camera_guide.png')),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 0,
            left: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _takePicture(); // 사진을 찍은 후 실행
                  // _imagePath가 제대로 설정된 경우만 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              CameraResultScreen(imagePath: _imagePath),
                    ),
                  );
                }, // 사진 찍기 버튼

                child: Icon(Icons.camera),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
