import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// [vipa] 프로젝트 공통 배경 위젯
/// 파고(fillLevel)와 색상(colors)을 자유롭게 조절할 수 있습니다.
class Background extends StatefulWidget {
  final Widget child;
  final List<Color>? colors; // 배경 그라데이션 색상
  final double fillLevel; // 물결의 높이 (0.0: 화면 최상단, 1.0: 화면 최하단)

  const Background({
    super.key,
    required this.child,
    this.colors,
    this.fillLevel = 0.3, // 기본값은 상단 30% 지점
  });

  @override
  State<Background> createState() => _BackgroundState();
}

class _BackgroundState extends State<Background>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 물결 애니메이션 실행
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
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
        return Stack(
          children: [
            // 바탕색
            Container(color: AppColors.background),
            // 물결 레이어
            ClipPath(
              clipper: WaveClipper(_controller.value, widget.fillLevel),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: widget.colors ?? [AppColors.wave, AppColors.wave],
                  ),
                ),
              ),
            ),
            // 실제 화면 컨텐츠
            widget.child,
          ],
        );
      },
    );
  }
}

/// 물결 모양을 깎아내는 클리퍼
class WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  final double fillLevel;

  WaveClipper(this.animationValue, this.fillLevel);

  @override
  Path getClip(Size size) {
    Path path = Path();
    double currentFill = size.height * fillLevel;

    path.lineTo(0, currentFill);

    // 물결 곡선 계산 로직 (수정 시 영향 없음)
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        currentFill +
            math.sin(
                  (i / size.width * 2 * math.pi) +
                      (animationValue * 2 * math.pi),
                ) *
                15,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
