import 'package:flutter/material.dart';

import 'app_colors.dart';

class Background extends StatelessWidget {
  const Background({
    super.key,
    required this.child,
    this.colors,
    this.fillLevel = 0.3,
  });

  final Widget child;
  final List<Color>? colors;
  final double fillLevel;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppColors.background, child: child);
  }
}
