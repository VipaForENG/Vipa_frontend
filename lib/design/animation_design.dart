import 'package:flutter/material.dart';
import 'dart:math' as math;

// 1. FadeSlideTransition (외부에서 쓸 수 있게 _ 제거)
class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final double delay;

  const FadeSlideTransition({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1250),
      curve: Interval(delay, 1.0, curve: Curves.easeOutExpo),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// 2. WaveBackground
class WaveBackground extends StatelessWidget {
  final Color waveColor;
  final double waveHeightFactor;

  const WaveBackground({
    super.key,
    required this.waveColor,
    required this.waveHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: waveHeightFactor),
      duration: const Duration(milliseconds: 1250),
      curve: Curves.easeInOutCubic,
      builder: (context, factor, child) {
        return LoopingWave( // _LoopingWave -> LoopingWave
          waveColor: waveColor,
          heightFactor: factor,
        );
      },
    );
  }
}

// 3. LoopingWave (외부에서 쓸 수 있게 _ 제거)
class LoopingWave extends StatefulWidget {
  final Color waveColor;
  final double heightFactor;

  const LoopingWave({super.key, required this.waveColor, required this.heightFactor});

  @override
  State<LoopingWave> createState() => _LoopingWaveState();
}

class _LoopingWaveState extends State<LoopingWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: WavePainter(
            waveAnimation: _controller.value,
            waveColor: widget.waveColor,
            heightFactor: widget.heightFactor,
          ),
        );
      },
    );
  }
}

// 4. WavePainter
class WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color waveColor;
  final double heightFactor;

  WavePainter({
    required this.waveAnimation,
    required this.waveColor,
    required this.heightFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = waveColor..style = PaintingStyle.fill;
    final Path path = Path();
    double baseHeight = size.height * (1.0 - heightFactor);
    double waveAmplitude = 15.0;

    path.moveTo(0, baseHeight);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        baseHeight + math.sin((i / size.width * 2 * math.pi) + (waveAnimation * 2 * math.pi)) * waveAmplitude,
      );
    }
    path.lineTo(size.width, size.height + 100);
    path.lineTo(0, size.height + 100);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}