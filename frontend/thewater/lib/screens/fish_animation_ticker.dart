import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:thewater/screens/fish_swimming.dart';

class FishAnimationTicker extends StatefulWidget {
  final FishSwimmingManager manager;
  const FishAnimationTicker({Key? key, required this.manager})
    : super(key: key);

  @override
  _FishAnimationTickerState createState() => _FishAnimationTickerState();
}

class _FishAnimationTickerState extends State<FishAnimationTicker>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      widget.manager.update();
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        children: [
          ...widget.manager.buildFallingFishes(),
          ...widget.manager.buildSwimmingFishes(),
          ...widget.manager.buildRemovalAnimations(),
        ],
      ),
    );
  }
}
