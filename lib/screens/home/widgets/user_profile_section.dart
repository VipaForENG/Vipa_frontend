import 'package:flutter/material.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 스케치의 메달/컵 모양 아이콘을 대체하는 위젯
        const Icon(Icons.workspace_premium, size: 80, color: Colors.brown),
        const SizedBox(height: 8),
        const Text(
          'BRONZE', // 사용자 등급 텍스트
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          '상위 86%', // 스케치에 있던 퍼센트 정보
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
        // 하단 화살표 아이콘 (추가 정보 보기 암시)
        const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
      ],
    );
  }
}