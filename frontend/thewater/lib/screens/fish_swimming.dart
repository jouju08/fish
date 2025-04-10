import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:ui';

class RemovalAnimationData {
  final String imagePath;
  final double startX;
  final double startY;
  final AnimationController controller;

  RemovalAnimationData({
    required this.imagePath,
    required this.startX,
    required this.startY,
    required this.controller,
  });
}

enum FishState { moving, idle }

class SwimmingFish {
  final String imagePath;
  final String fishName;
  double x;
  double y;
  double speed;
  FishState state;
  double dx;
  double dy;
  double stateTime;
  double stateDuration;
  bool isPaused;
  bool isDragging;

  // ← 새 필드: 롱프레스 타이머 (1초간 터치 감지)
  Timer? longPressTimer;

  SwimmingFish({
    required this.imagePath,
    required this.fishName,
    required this.x,
    required this.y,
    required this.speed,
    required this.state,
    required this.dx,
    required this.dy,
    required this.stateTime,
    required this.stateDuration,
    this.isPaused = false,
    this.isDragging = false,
  });
}

class FallingFish {
  final String imagePath;
  double top;
  bool landed;

  FallingFish({required this.imagePath, this.top = -100, this.landed = false});
}

class FishSwimmingManager {
  List<SwimmingFish> swimmingFishes = [];
  List<FallingFish> fallingFishes = [];
  List<RemovalAnimationData> removalAnimations = [];
  Timer? timer;

  final TickerProvider tickerProvider;
  final BuildContext context;
  final VoidCallback update;
  final Random random = Random();

  // 8방향 (상, 상우, 우, 우하, 하, 하좌, 좌, 좌상)
  final List<Map<String, double>> directions = [];

  FishSwimmingManager({
    required this.tickerProvider,
    required this.context,
    required this.update,
  }) {
    double invSqrt2 = 1 / sqrt(2);
    directions.addAll([
      {'dx': 0, 'dy': -1}, // 상
      {'dx': invSqrt2, 'dy': -invSqrt2}, // 상우
      {'dx': 1, 'dy': 0}, // 우
      {'dx': invSqrt2, 'dy': invSqrt2}, // 우하
      {'dx': 0, 'dy': 1}, // 하
      {'dx': -invSqrt2, 'dy': invSqrt2}, // 하좌
      {'dx': -1, 'dy': 0}, // 좌
      {'dx': -invSqrt2, 'dy': -invSqrt2}, // 좌상
    ]);
  }

  void startFishMovement() {
    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      update();
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;
      const double fishSize = 80.0; // 물고기 이미지 크기
      const double topBoundary = 120.0; // 상단 UI 영역 아래 (수족관 가치 영역)
      const double bottomBarHeight = 60.0; // 바텀 네비게이션 높이
      final double bottomBoundary =
          screenHeight - fishSize - bottomBarHeight; // 하단 경계

      for (var fish in swimmingFishes) {
        if (fish.isPaused || fish.isDragging) continue; // 일시정지 중이면 업데이트 건너뛰기
        // 매 업데이트마다 0.03초씩 경과 시간 업데이트
        fish.stateTime += 0.03;

        if (fish.state == FishState.moving) {
          // 0 ≤ t ≤ 1: 출발부터 정지까지의 진행 비율
          double t = fish.stateTime / fish.stateDuration;
          // sin(π * t)를 사용하여 t=0,1일 때 0, t=0.5일 때 최대 효과 (부드러운 가속/감속)
          double factor = sin(pi * t);
          double effectiveSpeed = fish.speed * factor;

          fish.x += fish.dx * effectiveSpeed;
          fish.y += fish.dy * effectiveSpeed;

          // 좌우 경계 체크
          if (fish.x < 0) {
            fish.x = 0;
            fish.dx = fish.dx.abs();
          } else if (fish.x > screenWidth - fishSize) {
            fish.x = screenWidth - fishSize;
            fish.dx = -fish.dx.abs();
          }
          // 상단 경계
          if (fish.y < topBoundary) {
            fish.y = topBoundary;
            fish.dy = fish.dy.abs();
          }
          // 하단 경계
          else if (fish.y > bottomBoundary) {
            fish.y = bottomBoundary;
            fish.dy = -fish.dy.abs();
          }

          if (fish.stateTime >= fish.stateDuration) {
            // 이동 상태 종료 후 idle 상태로 전환
            fish.state = FishState.idle;
            fish.stateTime = 0.0;
            // 정지 시간: 0~4초 (기존대로)
            fish.stateDuration = random.nextDouble() * 2.0;
          }
        } else {
          // idle 상태: 정지
          if (fish.stateTime >= fish.stateDuration) {
            // 정지 후 8방향 중 랜덤 선택하여 이동 시작
            int index = random.nextInt(directions.length);
            fish.dx = directions[index]['dx']!;
            fish.dy = directions[index]['dy']!;
            fish.state = FishState.moving;
            fish.stateTime = 0.0;
            // 이동 시간: 2초 ~ 3초
            fish.stateDuration = 2.0 + random.nextDouble() * 2.0;
          }
        }
      }
    });
  }

  void addFallingFish(String imagePath, String fishName) {
    debugPrint("addFallingFish() 실행됨 : $fishName");
    final newFish = FallingFish(imagePath: imagePath);
    fallingFishes.add(newFish);
    update();

    Future.delayed(Duration.zero, () {
      animateFishFall(newFish, fishName);
    });
  }

  void animateFishFall(FallingFish fish, String fishName) {
    const double targetY = 400;
    const double baseSpeed = 20;
    const double fishSize = 80.0;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      update();
      double progress = (fish.top / targetY).clamp(0.0, 1.0);
      double currentSpeed = baseSpeed * (1 - progress);

      // debugPrint("낙하진행중 : top=${fish.top},speed=$currentSpeed");

      if (fish.top <= targetY - 2) {
        fish.top += currentSpeed;
      } else {
        debugPrint("낙하완료 : $fishName 수영시작");
        fish.landed = true;
        timer.cancel();

        // 낙하 완료 후, 수영하는 물고기로 전환 (랜덤 방향 선택)
        int index = random.nextInt(directions.length);
        double dx = directions[index]['dx']!;
        double dy = directions[index]['dy']!;
        double movingDuration = 1.0 + random.nextDouble() * 2.0; // 이동시간

        SwimmingFish newSwimmingFish = SwimmingFish(
          imagePath: fish.imagePath,
          fishName: fishName,
          x: MediaQuery.of(context).size.width / 2 - fishSize / 2,
          y: fish.top,
          speed: 1.2 + random.nextDouble(),
          state: FishState.moving,
          dx: dx,
          dy: dy,
          stateTime: 0.0,
          stateDuration: movingDuration,
        );
        swimmingFishes.add(newSwimmingFish);
        fallingFishes.remove(fish);
        update();
      }
    });
  }

  void removeFishWithFishingLine(String imagePath) {
    debugPrint("물고기 제거 : $imagePath");
    final index = swimmingFishes.indexWhere(
      (fish) => fish.imagePath == imagePath,
    );
    if (index == -1) return;
    final fish = swimmingFishes[index];
    swimmingFishes.removeAt(index);

    final removalController = AnimationController(
      vsync: tickerProvider,
      duration: const Duration(milliseconds: 2000),
    );
    final removalData = RemovalAnimationData(
      imagePath: fish.imagePath,
      startX: fish.x,
      startY: fish.y,
      controller: removalController,
    );
    removalAnimations.add(removalData);

    removalController.addListener(() {
      update();
    });
    removalController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        removalAnimations.remove(removalData);
        removalController.dispose();
        update();
      }
    });
    removalController.forward();
  }

  void removeFish(String imagePath) {
    swimmingFishes.removeWhere((fish) => fish.imagePath == imagePath);
    fallingFishes.removeWhere((fish) => fish.imagePath == imagePath);
    update();
  }

  // ← 새 기능: 수영 중인 물고기를 1초간 터치했을 때 정보를 보여주는 다이얼로그
  void showFishDetailDialog(SwimmingFish fish) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 물고기 이미지 표시
                  Image.asset(
                    fish.imagePath,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 10),
                  // 물고기 이름 표시
                  Text(
                    fish.fishName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  // ※ 필요에 따라 추가적인 정보(예: 설명, 잡은 날짜 등)를 표시할 수 있음
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> buildRemovalAnimations() {
    // 물고기 이미지 크기 및 낚시줄의 가정된 크기
    const double fishSize = 80.0;
    const double lineHeight = 600.0; // 낚시줄 이미지의 세로 길이 (예시)
    const double lineWidth = 30.0; // 낚시줄 이미지의 가로 길이 (예시)

    return removalAnimations.map((data) {
      double t = data.controller.value; // 0 ~ 1 사이의 값
      double fishingLineBottomY;
      double fishY;
      if (t < 0.8) {
        // 낚시줄 내려오기 (0 ~ 0.8초)
        double stageT = t / 0.8; // 0~1 범위로 보정
        double easeT = 1 - pow(1 - stageT, 2).toDouble(); // ease-out 효과 적용
        fishingLineBottomY = lerpDouble(-lineHeight, data.startY + 50, easeT)!;
        fishY = data.startY; // 물고기는 고정
      } else {
        // 낚시줄과 함께 위로 이동 (0.8 ~ 1초)
        double stageT = (t - 0.8) / 0.2; // 0 ~ 1 범위로 
        fishY = data.startY + (-data.startY - fishSize) * stageT;
        // 낚시줄의 bottom도 같이 이동
        fishingLineBottomY =
            data.startY + (-data.startY + 50 - fishSize) * stageT;
      }
      // 낚시줄의 x 위치: 물고기 중앙 기준
      double lineX = data.startX + fishSize / 2 - lineWidth / 2;
      return Stack(
        children: [
          // 낚시줄 이미지
          Positioned(
            left: lineX,
            top: fishingLineBottomY - lineHeight,
            child: Image.asset(
              'assets/image/낚시줄.png',
              width: lineWidth,
              height: lineHeight,
              fit: BoxFit.fill,
            ),
          ),
          // 물고기 이미지
          Positioned(
            left: data.startX,
            top: fishY,
            child: Image.asset(data.imagePath, width: fishSize),
          ),
        ],
      );
    }).toList();
  }

  List<Widget> buildSwimmingFishes() {
    const double fishSize = 80;
    return swimmingFishes.map((fish) {
      return Positioned(
        top: fish.y,
        left: fish.x,
        child: GestureDetector(
          // ← 새 기능: 1초간 터치(롱프레스) 감지
          onTapDown: (details) {
            // 드래그 시작 전에 롱프레스 타이머 시작
            fish.longPressTimer = Timer(const Duration(seconds: 1), () {
              showFishDetailDialog(fish);
            });
          },
          onTapUp: (_) {
            fish.longPressTimer?.cancel();
            fish.longPressTimer = null;
          },
          onTapCancel: () {
            fish.longPressTimer?.cancel();
            fish.longPressTimer = null;
          },
          // 기존의 드래그 관련 이벤트에도 롱프레스 타이머 취소 추가
          onPanStart: (_) {
            fish.longPressTimer?.cancel();
            fish.longPressTimer = null;
            fish.isDragging = true;
            fish.isPaused = true;
          },
          onPanUpdate: (details) {
            fish.x += details.delta.dx;
            fish.y += details.delta.dy;
            update(); // 위치 갱신
          },
          onPanEnd: (_) {
            fish.isDragging = false;
            Timer(const Duration(milliseconds: 1500), () {
              fish.isPaused = false;
              update();
            });
          },
          child: Container(
            width: fishSize,
            height: fishSize + 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform(
                  alignment: Alignment.center,
                  transform: fish.dx < 0
                      ? Matrix4.rotationY(pi)
                      : Matrix4.identity(),
                  child: Image.asset(
                    fish.imagePath,
                    width: fishSize,
                    height: fishSize,
                    fit: BoxFit.contain,
                  ),
                ),
                if (fish.isPaused)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: _buildFishNameOverlay(fish.fishName),
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildFishNameOverlay(String fishName) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: const Duration(milliseconds: 1500),
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: Container(
        padding: const EdgeInsets.all(4.0),
        child: Text(
          fishName,
          style: const TextStyle(
            color: Color.fromARGB(255, 0, 0, 0),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  List<Widget> buildFallingFishes() {
    return fallingFishes.map((fish) {
      return Positioned(
        top: fish.top,
        left: MediaQuery.of(context).size.width / 2 - 40,
        child: Image.asset(fish.imagePath, width: 80),
      );
    }).toList();
  }

  void dispose() {
    timer?.cancel();
    for (var data in removalAnimations) {
      data.controller.dispose();
    }
  }
}
