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
  // final String fishName; // 백엔드 연동할때 받을 String fishName
  double x;
  double y;
  double speed;
  FishState state;
  double dx;
  double dy;
  double stateTime;
  double stateDuration;
  bool isPaused; // 일시정지 여부

  SwimmingFish({
    required this.imagePath,
    // required this.fishName, // 물고기 이름을 받아서 저장
    required this.x,
    required this.y,
    required this.speed,
    required this.state,
    required this.dx,
    required this.dy,
    required this.stateTime,
    required this.stateDuration,
    this.isPaused = false,
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
        if (fish.isPaused) continue; // 일시정지 중이면 업데이트 건너뛰기
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
            fish.stateDuration = random.nextDouble() * 4.0;
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
            // 이동 시간: 1초 ~ 3초
            fish.stateDuration = 1.0 + random.nextDouble() * 2.0;
          }
        }
      }
    });
  }

  void addFallingFish(String imagePath) {
    final newFish = FallingFish(imagePath: imagePath);
    fallingFishes.add(newFish);
    animateFishFall(newFish);
  }

  void animateFishFall(FallingFish fish) {
    const double targetY = 400;
    const double baseSpeed = 20;
    const double fishSize = 80.0;
    Timer.periodic(const Duration(milliseconds: 16), (timer) {
      update();
      double progress = (fish.top / targetY).clamp(0.0, 1.0);
      double currentSpeed = baseSpeed * (1 - progress);

      if (fish.top <= targetY - 2) {
        fish.top += currentSpeed;
      } else {
        fish.landed = true;
        timer.cancel();

        // 낙하 완료 후, 수영하는 물고기로 전환 (랜덤 방향 선택)
        int index = random.nextInt(directions.length);
        double dx = directions[index]['dx']!;
        double dy = directions[index]['dy']!;
        double movingDuration = 1.0 + random.nextDouble() * 2.0; // 1~3초 이동
        SwimmingFish newSwimmingFish = SwimmingFish(
          imagePath: fish.imagePath,
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
      }
    });
  }

  void removeFishWithFishingLine(String imagePath) {
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
        double stageT = (t - 0.8) / 0.2; // 0 ~ 1 범위로 보정
        // 물고기는 data.startY에서 화면 위(예: -fishSize)까지 이동
        fishY = data.startY + (-data.startY - fishSize) * stageT;
        // 낚시줄의 bottom도 같이 이동
        fishingLineBottomY =
            data.startY + (-data.startY + 50 - fishSize) * stageT;
      }
      // 낚시줄의 x 위치: 물고기 중앙 기준 (fishSize/2)에서 낚시줄 width 절반만큼 왼쪽 이동
      double lineX = data.startX + fishSize / 2 - lineWidth / 2;
      return Stack(
        children: [
          // 낚시줄 이미지: Positioned의 top은 fishingLineBottomY - lineHeight로 계산
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
          // 물고기 이미지: 현재 y 위치에 그림
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
    return swimmingFishes.map((fish) {
      return Positioned(
        top: fish.y,
        left: fish.x,
        child: GestureDetector(
          onTap: () {
            // 이미 일시정지 중이면 아무것도 하지 않음
            if (!fish.isPaused) {
              fish.isPaused = true;
              update();

              // 1.5초 후 일시정지 해제
              Timer(const Duration(milliseconds: 1500), () {
                fish.isPaused = false;
                update();
              });
            }
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 물고기 이미지 (좌우 반전 처리 포함)
              Transform(
                alignment: Alignment.center,
                transform:
                    fish.dx < 0 ? Matrix4.rotationY(pi) : Matrix4.identity(),
                child: Image.asset(fish.imagePath, width: 80),
              ),
              // 일시정지 상태라면 물고기 이름 오버레이 (1.5초 동안 opacity 애니메이션)
              if (fish.isPaused)
                Positioned(
                  bottom: 50,
                  child: Center(child: _buildFishNameOverlay("간지렁~!")),
                ),
            ],
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
