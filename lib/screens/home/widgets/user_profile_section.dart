import 'package:flutter/material.dart';

class UserProfileSection extends StatelessWidget {
  const UserProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Card_Container 내부에서 적절한 간격을 유지하기 위해 Padding으로 감쌉니다.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20), // 위아래 여백 추가
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용물만큼만 높이 차지
        children: [
          // 1. 등급 아이콘 (브론즈 느낌의 색상 유지)
          const Icon(
            Icons.workspace_premium, 
            size: 80, 
            color: Color(0xFFCD7F32) // 실제 브론즈 색상에 가까운 톤
          ),
          const SizedBox(height: 8),

          // 2. 등급 텍스트 (디자인 시스템의 메인 컬러 적용)
          const Text(
            'BRONZE',
            style: TextStyle(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF2D3436), // 디자인 프로젝트 공통 컬러
              letterSpacing: 1.2, // 텍스트 자간을 넓혀 고급스럽게
            ),
          ),

          // 3. 퍼센트 정보
          Text(
            '상위 86%',
            style: TextStyle(
              fontSize: 16, 
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 8),

          // 4. 하단 화살표 (부드러운 색상)
          const Icon(
            Icons.keyboard_arrow_down, 
            color: Color(0xFFDFE6E9), // 연한 회색으로 강조 완화
          ),
        ],
      ),
    );
  }
}