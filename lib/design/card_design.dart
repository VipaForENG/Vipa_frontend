import 'package:flutter/material.dart';
import 'dart:ui';

Widget cardContainer({double? height, required Widget child}) {
  return Container(
    width: double.infinity,
    height: height,
    margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24), // 곡률을 살짝 높여 더 부드럽게
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // 블러 강도 강화
        child: Container(
          decoration: BoxDecoration(
            // 배경 파도색에 맞춘 미세한 노란빛 투명도
            color: Colors.white.withValues(alpha: 0.4), 
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        ),
      ),
    ),
  );
}