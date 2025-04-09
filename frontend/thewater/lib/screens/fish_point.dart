import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image/image.dart';
import 'package:provider/provider.dart';
import 'package:thewater/providers/env_provider.dart';
import 'package:thewater/providers/point_provider.dart';
import 'package:thewater/screens/tide_chart.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({super.key});

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final TextEditingController _markerNameController = TextEditingController(
    text: "낚시 포인트",
  );
  final TextEditingController _commentController = TextEditingController(
    text: "낚시 포인트 댓글",
  );
  final tableScrollController = ScrollController();
  final chartScrollController = ScrollController();
  late GoogleMapController mapController;
  late LatLng _lastTappedLocation; // 마지막 클릭한 위치 저장용
  LatLng _center = const LatLng(34.70, 127.66);
  Set<Marker> markers = {}; // 마커를 저장할 Set
  Set<Marker> markersKorea = {}; // 마커를 저장할 List
  Marker? _selectedMarker; // 선택된 마커 저장
  Timer? _tapTimer; // 길게 누른 타이머
  List<String> propertyList = [
    '시간',
    '환경',
    '날씨',
    '기온',
    '강수',
    '풍속',
    '풍향',
    '파고',
    '수온',
  ];
  int riseIndex = 0;
  bool onlyMyPoint = false; // 내 마커만 보기

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
    _loadMarkers();
    tableScrollController.addListener(_onScroll);
    tableScrollController.addListener(() {
      if (chartScrollController.hasClients &&
          chartScrollController.offset != tableScrollController.offset) {
        chartScrollController.jumpTo(tableScrollController.offset);
      }
    });

    chartScrollController.addListener(() {
      if (tableScrollController.hasClients &&
          tableScrollController.offset != chartScrollController.offset) {
        tableScrollController.jumpTo(chartScrollController.offset);
      }
    });
  }

  Future<void> requestLocationPermission() async {
    // 위치 권한 요청
    PermissionStatus status = await Permission.location.request();
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low,
    );
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
    });
    mapController.animateCamera(CameraUpdate.newLatLngZoom(_center, 11.0));
    // 권한 상태 확인
    if (status.isGranted) {
      // 권한이 허용된 경우
      print('위치 권한이 허용되었습니다.');
    } else if (status.isDenied) {
      // 권한이 거부된 경우
      print('위치 권한이 거부되었습니다.');
      // 사용자에게 권한의 필요성을 설명하는 다이얼로그를 표시할 수 있습니다.
    } else if (status.isPermanentlyDenied) {
      // 권한이 영구적으로 거부된 경우 설정으로 이동하도록 안내
      print('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 활성화해주세요.');
    }
  }

  void _onScroll() {
    final offset = tableScrollController.offset;
    final calculatedIndex = (offset / 10).round();

    setState(() {
      riseIndex = calculatedIndex.clamp(0, 6);
    });
  }

  void _loadMarkers() async {
    await Provider.of<PointModel>(context, listen: false).getPointList();
    await Provider.of<PointModel>(context, listen: false).getMyPointList();
    // Provider에서 포인트 리스트 가져오기
    final points = Provider.of<PointModel>(context, listen: false).pointList;
    final myPoints =
        Provider.of<PointModel>(context, listen: false).myPointList;
    setState(() {
      debugPrint("포인트 리스트: $points");
      debugPrint("내 포인트 리스트: $myPoints");
      markers =
          myPoints.map((point) {
            final lat = point['latitude'];
            final lon = point['longitude'];
            final marker = Marker(
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueBlue,
              ),
              markerId: MarkerId(point['pointId'].toString()),
              position: LatLng(lat, lon),
              infoWindow: InfoWindow(title: point['pointName']),
              onTap: () {
                debugPrint("marker onTap 함수 호출");
                setState(() {
                  _selectedMarker = markers.firstWhere(
                    (marker) =>
                        marker.markerId.value == point['pointId'].toString(),
                  );
                });
              },
            );
            return marker;
          }).toSet();
      // 마커 리스트를 가져오기
      markersKorea =
          points.map((point) {
            final lat = double.parse(point['latitude']);
            final lon = double.parse(point['longitude']);
            return Marker(
              markerId: MarkerId(point['id'].toString()),
              position: LatLng(lat, lon),
              infoWindow: InfoWindow(title: point['pointName']),
              onTap: () {
                debugPrint("marker onTap 함수 호출");
                setState(() {
                  _selectedMarker = markersKorea.firstWhere(
                    (marker) => marker.markerId.value == point['id'].toString(),
                  );
                });
              },
            );
          }).toSet();
    });
  }

  void _deleteSelectedMarker() {
    setState(() {
      if (_selectedMarker != null) {
        Provider.of<PointModel>(
          context,
          listen: false,
        ).deletePoint(int.parse(_selectedMarker!.markerId.value)).then((_) {
          debugPrint("마커 삭제 Provider 함수 실행 완료");
        });
        markers.removeWhere((marker) => marker == _selectedMarker); // 마커 삭제
        markersKorea.removeWhere(
          (marker) => marker == _selectedMarker,
        ); // 마커 삭제
        _selectedMarker = null; // 선택된 마커 초기화
      }
    });
    Navigator.pop(context); // BottomSheet 닫기
    debugPrint("after delete $markers");
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

  void _showBottomSheet() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        double? lat = _selectedMarker?.position.latitude;
        double? lon = _selectedMarker?.position.longitude;

        if (lat == null || lon == null) {
          return const Center(child: Text("위치 정보가 없습니다"));
        }

        // 여러 Future를 동시에 기다리기 위해 Future.wait 사용
        final futures = Future.wait([
          Provider.of<EnvModel>(
            context,
            listen: false,
          ).getWaterTempList(lat, lon),
          Provider.of<EnvModel>(context, listen: false).getTide(lat, lon),
          Provider.of<EnvModel>(
            context,
            listen: false,
          ).getRiseSetList(lat, lon),
          Provider.of<EnvModel>(
            context,
            listen: false,
          ).getWeatherList(lat, lon),
        ]);

        return FutureBuilder<List<dynamic>>(
          future: futures,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("에러 발생: ${snapshot.error}"));
            } else if (!snapshot.hasData) {
              return const Center(child: Text("데이터가 없습니다"));
            }

            final waterTempList = snapshot.data![0];
            final tideList = snapshot.data![1];
            final riseSetList = snapshot.data![2];
            final weatherList = snapshot.data![3];

            return Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedMarker?.infoWindow.title ?? "마커 정보",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: _deleteSelectedMarker,
                          child: Text("삭제"),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(weatherList[0]["fcstDate"]),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        // 2. 왼쪽 속성 고정
                        Column(
                          children:
                              propertyList
                                  .map(
                                    (property) => Container(
                                      height: 40,
                                      alignment: Alignment.centerLeft,
                                      width: 40,
                                      child: Text(property),
                                    ),
                                  )
                                  .toList(),
                        ),
                        // 3. 데이터 테이블 (가로 스크롤 영역)
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            controller: tableScrollController,
                            child: Row(
                              children: List.generate(weatherList.length, (
                                colIdx,
                              ) {
                                return Column(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(
                                        weatherList[colIdx]["fcstTime"],
                                      ),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text("좋음"),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(weatherList[colIdx]["SKY"]),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(weatherList[colIdx]["TMP"]),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(weatherList[colIdx]["PCP"]),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(weatherList[colIdx]["WSD"]),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(weatherList[colIdx]["VEC"]),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(weatherList[colIdx]["WAV"]),
                                    ),
                                    Container(
                                      width: 60,
                                      height: 40,
                                      alignment: Alignment.center,
                                      child: Text(
                                        waterTempList[colIdx]["temperature"],
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 360,
                      child: TideChart(
                        tideData: tideList,
                        scrollController: chartScrollController,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(riseSetList[riseIndex]["sunrise"]),
                    Text("🌞 Rise/Set List:\n${jsonEncode(riseSetList)}"),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showMarkerConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            '마커를 추가하시겠습니까?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: _markerNameController,
            decoration: const InputDecoration(hintText: "마커 이름을 입력하세요"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                '취소',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                // 마커 추가
                Provider.of<PointModel>(context, listen: false)
                    .addPoint(
                      _markerNameController.text.trim(),
                      _lastTappedLocation.latitude,
                      _lastTappedLocation.longitude,
                      _markerNameController.text.trim(),
                    )
                    .then((_) {
                      debugPrint("마커 추가 Provider 함수 실행 완료");
                    });
                setState(() {
                  String markerIdStr =
                      _lastTappedLocation.toString(); // 마커 ID 저장
                  String markerName = _markerNameController.text.trim();
                  // 새 마커 생성
                  Marker newMarker = Marker(
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue,
                    ),
                    markerId: MarkerId(markerIdStr),
                    position: _lastTappedLocation,
                    infoWindow: InfoWindow(title: markerName),
                    onTap: () {
                      debugPrint("marker onTap 함수 호출");
                      setState(() {
                        _selectedMarker = markersKorea
                            .union(markers)
                            .firstWhere(
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
                  markers.add(newMarker);
                  _markerNameController.text = "낚시 포인트";
                });
                Navigator.of(context).pop();
              },
              child: const Text(
                '확인',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    // 타이머가 있다면 dispose 시 종료
    _tapTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                onlyMyPoint = !onlyMyPoint;
              });
            },
            child:
                onlyMyPoint
                    ? Text(
                      "모든 마커 보기",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                    : Text(
                      "내 마커만 보기",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
          ),
        ],
        title: const Text(
          '낚시 포인트',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        child: Stack(
          children: [
            GoogleMap(
              mapToolbarEnabled: false,
              myLocationEnabled: true, // 사용자의 현재 위치 표시
              myLocationButtonEnabled: true, // 우측 하단 현위치 버튼
              compassEnabled: true,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers:
                  onlyMyPoint
                      ? markers
                      : markersKorea.union(markers), // 현재 마커를 GoogleMap에 표시
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
                bottom: 50, // 화면 높이 중앙 (버튼 높이 고려)
                left:
                    MediaQuery.of(context).size.width / 2 -
                    65, // 화면 너비 중앙 (버튼 너비 고려)
                child: ElevatedButton(
                  onPressed: _showBottomSheet,
                  child: const Text(
                    '상세 정보 보기',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
