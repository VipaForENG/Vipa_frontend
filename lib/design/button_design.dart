import 'package:flutter/material.dart';

Widget buttonDesign(String title, IconData icon, VoidCallback onPressed) {
  return Expanded(
    child: SizedBox(
      height: 120,
      child: ElevatedButton(
        onPressed: onPressed, // 1. 클릭 시 실행될 함수 연결
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // 배경색
          foregroundColor: const Color(0xFF2D3436), // 클릭 시 퍼지는 색상 (물결 효과)
          elevation: 0, // 그림자 제거 (깔끔하게)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 테두리 둥글게
            side: const BorderSide(color: Color(0xFFEDF0F3)), // 테두리 선
          ),
          padding: EdgeInsets.zero, // 내부 기본 패딩 제거
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF2D3436), size: 30),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}