import 'package:flutter/material.dart';

class UserProfileSection extends StatelessWidget {
  final String nickname;
  final String tier;
  final double topPercent;
  final int studyAchievementRate;
  
  const UserProfileSection({
    super.key,
    required this.nickname,
    required this.tier,
    required this.topPercent,
    required this.studyAchievementRate,
  });

@override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24), // 가로 패딩 추가
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 등급 아이콘 및 정보 (기존 코드)
          const Icon(Icons.workspace_premium, size: 80, color: Color(0xFFCD7F32)),
          const SizedBox(height: 8),
          Text(
            tier.toUpperCase(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3436), letterSpacing: 1.2),
          ),
          Text(
            '상위 ${topPercent.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 16, color: Colors.grey[500], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            nickname,
            style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
          
          // -------------------------------------------------------
          // 2. 오늘의 목표 달성률 섹션 추가
          // -------------------------------------------------------
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "오늘의 목표 달성률",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
                  ),
                  Text(
                    "$studyAchievementRate%",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect( // 테두리를 둥글게 깎음
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: studyAchievementRate / 100,
                  minHeight: 8, // 바의 두께 조절
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
            ],
          ),
          // -------------------------------------------------------

          const Icon(Icons.keyboard_arrow_down, color: Color(0xFFDFE6E9)),
        ],
      ),
    );
  }
}