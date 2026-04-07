import 'package:flutter/material.dart';

/// Vipa 프로젝트의 공통 사각형 버튼 위젯입니다.
/// [title]: 버튼에 표시될 텍스트
/// [icon]: 상단에 표시될 아이콘 데이터
/// [onPressed]: 버튼 클릭 시 실행될 콜백 함수
Widget vipaPrimaryButton({
  required String title,
  required IconData icon,
  required VoidCallback onPressed,
  double height = 120.0, // 기본 높이 설정
}) {
  return SizedBox(
    height: height,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3436), // 클릭 시 물결 효과 색상
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFEDF0F3)),
        ),
        padding: EdgeInsets.zero,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2D3436), size: 30),
          const SizedBox(height: 8), // 간격을 살짝 넓혀 가독성 확보
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    ),
  );
}
