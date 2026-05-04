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

  // [통합] 티어 문자열에 따라 동적으로 색상을 반환하는 헬퍼 함수
  Color _getTierColor(String currentTier) {
    switch (currentTier.toUpperCase()) {
      case 'BRONZE':
        return const Color.fromARGB(255, 194, 114, 35);
      case 'SILVER':
        return const Color.fromARGB(255, 192, 192, 192);
      case 'GOLD':
        return const Color.fromARGB(255, 255, 215, 0);
      default:
        return const Color.fromARGB(255, 205, 127, 50); // 기본값 방어
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24), // 가로 패딩 추가
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 등급 아이콘 및 정보 (동적 색상 적용)
          Icon(Icons.workspace_premium, size: 80, color: _getTierColor(tier)),
          const SizedBox(height: 8),
          Text(
            tier.toUpperCase(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3436), letterSpacing: 1.2),
          ),
          Text(
            '상위 ${topPercent.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 32, 32, 32), fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            nickname,
            style: const TextStyle(fontSize: 14, color: Color.fromARGB(255, 179, 146, 0), fontWeight: FontWeight.bold),
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
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 32, 32, 32)),
                  ),
                  Text(
                    "$studyAchievementRate%",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 179, 146, 0)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect( // 테두리를 둥글게 깎음
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  // [통합 핵심] 데이터가 100 이상이 들어와도 0.0 ~ 1.0 사이로 강제 고정 (UI 터짐 방지)
                  value: (studyAchievementRate / 100).clamp(0.0, 1.0),
                  minHeight: 8, // 바의 두께 조절
                  backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 179, 146, 0)),
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