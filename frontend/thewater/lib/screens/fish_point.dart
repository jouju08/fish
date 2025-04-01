import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _markerNameController = TextEditingController(
    text: "낚시 포인트",
  );
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(34.70, 127.66);
  final Set<Marker> _markers = {}; // 마커를 저장할 Set

  Marker? _selectedMarker; // 선택된 마커 저장

  late LatLng _lastTappedLocation; // 마지막 클릭한 위치 저장용
  Timer? _tapTimer; // 길게 누른 타이머

  void _deleteSelectedMarker() {
    setState(() {
      if (_selectedMarker != null) {
        _markers.removeWhere((marker) => marker == _selectedMarker); // 마커 삭제
        _selectedMarker = null; // 선택된 마커 초기화
      }
    });
    debugPrint("after delete $_markers");
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onLongPress(LatLng tappedPoint) {
    // 타이머를 설정하여 0.2 초동안 길게 눌렀을 때 모달을 뜨우기
    _tapTimer = Timer(const Duration(milliseconds: 200), () {
      _showMarkerConfirmationDialog();
    });
  }

  void _showMarkerConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('마커를 추가하시겠습니까?'),
          content: TextField(
            controller: _markerNameController,
            decoration: const InputDecoration(hintText: "마커 이름을 입력하세요"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // 마커 추가
                setState(() {
                  String markerIdStr =
                      _lastTappedLocation.toString(); // 마커 ID 저장
                  String markerName = _markerNameController.text.trim();
                  // 새 마커 생성
                  Marker newMarker = Marker(
                    markerId: MarkerId(markerIdStr),
                    position: _lastTappedLocation,
                    infoWindow: InfoWindow(title: markerName),
                    onTap: () {
                      debugPrint("marker onTap 함수 호출");
                      setState(() {
                        _selectedMarker = _markers.firstWhere(
                          (marker) => marker.markerId.value == markerIdStr,
                        );
                      });
                    },
                    onDrag: (LatLng latlng) {
                      setState(() {
                        _selectedMarker = null;
                      });
                    },
                  );
                  // 생성된 마커를 _markers에 추가
                  _markers.add(newMarker);
                  _markerNameController.text = "낚시 포인트";
                });
                Navigator.of(context).pop();
              },
              child: const Text('확인'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('취소'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('낚시 포인트를 저장해보세요'),
        backgroundColor: Colors.green[700],
      ),
      body: GestureDetector(
        child: Stack(
          children: [
            GoogleMap(
              mapToolbarEnabled: false,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: _markers, // 현재 마커를 GoogleMap에 표시
              onMapCreated: _onMapCreated,
              onLongPress: (LatLng tappedPoint) {
                _lastTappedLocation = tappedPoint;
                _onLongPress(_lastTappedLocation);
              },
              onTap: (LatLng tappedPoint) {
                // 맵의 빈 공간을 클릭하면 선택된 마커를 해제
                setState(() {
                  _selectedMarker = null;
                });
              },
            ),
            if (_selectedMarker != null) // 선택된 마커가 있을 때만 나타나기
              Positioned(
                top: 20,
                right: 20,
                child: ElevatedButton(
                  onPressed: _deleteSelectedMarker,
                  child: const Text('마커 삭제'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 타이머가 있다면 dispose 시 종료
    _tapTimer?.cancel();
    super.dispose();
  }
}
