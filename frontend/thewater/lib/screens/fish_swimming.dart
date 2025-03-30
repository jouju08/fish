import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

enum FishState { moving, idle }

class SwimmingFish {
  final String imagePath;
  double x;
  double y;
  double speed;
  double angle;

  // 상태 관련 변수
  FishState state;
  double dx; // 이동 방향 x (단위벡터)
  double dy; // 이동 방향 y (단위벡터)
  double stateTime; // 현재 상태에서 경과한 시간(초)
  double stateDuration; // 현재 상태의 지속 시간(초)

  SwimmingFish({
    required this.imagePath,
    required this.x,
    required this.y,
    required this.speed,
    required this.angle,
    required this.state,
    required this.dx,
    required this.dy,
    required this.stateTime,
    required this.stateDuration,
  });
}

class FallingFish {
  final String imagePath;
  double top;
  bool landed;

  FallingFish({
    required this.imagePath,
    this.top = 0.0,
    this.landed = false,
  });
}

class FishSwimmingManager {
  List<SwimmingFish> swimmingFishes = [];
  List<FallingFish> fallingFishes = [];
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
      {'dx': 0, 'dy': -1},             // 상
      {'dx': invSqrt2, 'dy': -invSqrt2}, // 상우
      {'dx': 1, 'dy': 0},              // 우
      {'dx': invSqrt2, 'dy': invSqrt2},  // 우하
      {'dx': 0, 'dy': 1},              // 하
      {'dx': -invSqrt2, 'dy': invSqrt2}, // 하좌
      {'dx': -1, 'dy': 0},             // 좌
      {'dx': -invSqrt2, 'dy': -invSqrt2},// 좌상
    ]);
  }

  void startFishMovement() {
    timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      update();
      final double screenWidth = MediaQuery.of(context).size.width;
      final double screenHeight = MediaQuery.of(context).size.height;
      const double fishSize = 80.0;         // 물고기 이미지 크기
      const double topBoundary = 120.0;       // 상단 UI(수족관 가치 영역) 아래 경계
      const double bottomBarHeight = 60.0;    // 바텀 네비게이션 높이 (예시)
      final double bottomBoundary =
          screenHeight - fishSize - bottomBarHeight; // 하단 경계

      for (var fish in swimmingFishes) {
        // 매 업데이트마다 0.03초씩 경과 시간 업데이트
        fish.stateTime += 0.03;

        if (fish.state == FishState.moving) {
          // t: 0에서 1 사이 (출발부터 정지까지)
          double t = fish.stateTime / fish.stateDuration;
          // sin(pi*t)를 사용하면 t=0,1일 때 0, t=0.5일 때 최대 효과
          double factor = sin(pi * t);
          double effectiveSpeed = fish.speed * factor;

          // 이동: effectiveSpeed로 부드러운 가속/감속 적용
          fish.x += fish.dx * effectiveSpeed;
          fish.y += fish.dy * effectiveSpeed;

          // 좌우 경계 체크
          if (fish.x < 0) {
            fish.x = 0;
            fish.dx = fish.dx.abs(); // 오른쪽으로 전환
          } else if (fish.x > screenWidth - fishSize) {
            fish.x = screenWidth - fishSize;
            fish.dx = -fish.dx.abs(); // 왼쪽으로 전환
          }
          // 상단 경계: 상단 UI 영역 아래로
          if (fish.y < topBoundary) {
            fish.y = topBoundary;
            fish.dy = fish.dy.abs(); // 아래로 전환
          }
          // 하단 경계: 바텀 네비게이션 위까지만
          else if (fish.y > bottomBoundary) {
            fish.y = bottomBoundary;
            fish.dy = -fish.dy.abs(); // 위로 전환
          }

          if (fish.stateTime >= fish.stateDuration) {
            // 이동 상태 종료 후 idle 상태로 전환
            fish.state = FishState.idle;
            fish.stateTime = 0.0;
            fish.stateDuration = random.nextDouble() * 4.0; // 0 ~ 4초 정지
          }
        } else {
          // idle 상태에서는 움직이지 않음
          if (fish.stateTime >= fish.stateDuration) {
            // 정지 후 8방향 중 랜덤 선택하여 이동 시작
            int index = random.nextInt(directions.length);
            fish.dx = directions[index]['dx']!;
            fish.dy = directions[index]['dy']!;
            // 좌우 반전만 적용하므로 angle은 사용하지 않음.
            fish.state = FishState.moving;
            fish.stateTime = 0.0;
            fish.stateDuration = random.nextDouble() * 2.0; // 0 ~ 2초 이동
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
        double angle = 0; // 좌우 반전만 적용하므로 별도 회전 없음
        double movingDuration = random.nextDouble() * 2.0; // 0 ~ 2초 이동
        SwimmingFish newSwimmingFish = SwimmingFish(
          imagePath: fish.imagePath,
          x: MediaQuery.of(context).size.width / 2 - fishSize / 2,
          y: fish.top,
          speed: 1.2 + random.nextDouble(),
          angle: angle,
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

  List<Widget> buildSwimmingFishes() {
    return swimmingFishes.map((fish) {
      return Positioned(
        top: fish.y,
        left: fish.x,
        child: Transform(
          alignment: Alignment.center,
          // 좌우 반전만 적용: dx가 음수이면 수평 플립, 그 외는 그대로
          transform: fish.dx < 0 ? Matrix4.rotationY(pi) : Matrix4.identity(),
          child: Image.asset(fish.imagePath, width: 80),
        ),
      );
    }).toList();
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
  }
}
