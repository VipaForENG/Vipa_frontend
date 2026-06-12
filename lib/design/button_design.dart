import 'package:flutter/material.dart';

/// Vipa 프로젝트의 공통 사각형 버튼 위젯입니다.
/// [title]: 버튼에 표시될 텍스트
/// [icon]: 상단에 표시될 아이콘 데이터
/// [onPressed]: 버튼 클릭 시 실행될 콜백 함수
Widget vipaPrimaryButton({
  required String title,
  required IconData icon,
  required VoidCallback onPressed,
  double height = 54.0,
}) {
  return SizedBox(
    height: height,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFF4F39),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  );
}
