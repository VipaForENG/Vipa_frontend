import 'package:flutter/material.dart';

class UserProfileSection extends StatelessWidget {
  final String nickname;
  final String tier;
  final double topPercent;

  const UserProfileSection({
    super.key,
    required this.nickname,
    required this.tier,
    required this.topPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 등급 아이콘
          const Icon(
            Icons.workspace_premium,
            size: 80,
            color: Color(0xFFCD7F32), // 브론즈 색상 (티어에 따라 색상 로직 추가 가능)
          ),
          const SizedBox(height: 8),

          // 2. 등급 텍스트 (티어 이름 출력)
          Text(
            tier.toUpperCase(),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
              letterSpacing: 1.2,
            ),
          ),

          // 3. 퍼센트 정보 (백엔드 데이터 반영)
          Text(
            '상위 ${topPercent.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // 4. 추가 텍스트 (닉네임 표시)
          Text(
            nickname,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFFDFE6E9),
          ),
        ],
      ),
    );
  }
}