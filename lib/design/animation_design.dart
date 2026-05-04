import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 🌊 [WaveBackground] 
/// 외부에서 넘겨받은 waveHeightFactor(0.0 ~ 1.0)에 따라 물결의 높이를 결정합니다.
class WaveBackground extends StatelessWidget {
  final Color waveColor;
  final double waveHeightFactor; // 0.0: 바닥, 1.0: 화면 전체 채움

  const WaveBackground({
    super.key,
    required this.waveColor,
    required this.waveHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    return LoopingWave(
      waveColor: waveColor,
      heightFactor: waveHeightFactor,
    );
  }
}

class LoopingWave extends StatefulWidget {
  final Color waveColor;
  final double heightFactor;

  const LoopingWave({super.key, required this.waveColor, required this.heightFactor});

  @override
  State<LoopingWave> createState() => _LoopingWaveState();
}

class _LoopingWaveState extends State<LoopingWave> with SingleTickerProviderStateMixin {
  late AnimationController _loopController;

  @override
  void initState() {
    super.initState();
    // 물결이 좌우로 계속 일렁이게 만드는 루프 애니메이션
    _loopController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _loopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _loopController,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: WavePainter(
            waveAnimation: _loopController.value,
            waveColor: widget.waveColor,
            heightFactor: widget.heightFactor, // 위아래 높이 결정 인자
          ),
        );
      },
    );
  }
}

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
    
    // 💡 영상 속 연출의 핵심: heightFactor가 1.0에 가까워질수록 baseHeight는 0(화면 상단)이 됩니다.
    double baseHeight = size.height * (1.0 - heightFactor);
    double waveAmplitude = 20.0; // 일렁임의 크기

    path.moveTo(0, baseHeight);
    
    // 물결 곡선 그리기
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        baseHeight + math.sin((i / size.width * 2 * math.pi) + (waveAnimation * 2 * math.pi)) * waveAmplitude,
      );
    }
    
    // 물결 아래쪽을 사각형으로 채움
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => true;
}

/// ✨ [FadeSlideTransition]
/// 카드들이 아래에서 위로 나타나는 효과
class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final double delay;

  const FadeSlideTransition({super.key, required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      // 시작 지연을 주어 물결이 올라온 뒤 카드가 보이게 함
      curve: Interval(delay, 1.0, curve: Curves.easeOutCubic),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 50 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}