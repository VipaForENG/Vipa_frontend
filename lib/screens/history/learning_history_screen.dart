import 'package:flutter/material.dart';

/// [클래스] LearningHistoryScreen
/// 목적: '내가 학습한 내역'을 실전회화, 단어, 문법 카테고리별로 그룹화하여 보여줍니다.
class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // 살짝 밝은 그레이 배경으로 카드 부각
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('학습내역',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      // [위젯] SingleChildScrollView: 카테고리가 많아질 경우 전체 스크롤 가능하게 함
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [텍스트] 상단 소제목: 내가 학습한 내역
            const Text('내가 학습한 내역',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 20),

            // 1. 실전회화 섹션
            _buildCategoryCard(
              title: '실전회화',
              icon: Icons.chat_bubble_rounded,
              color: Colors.blueAccent,
              items: ['일별 학습 회화', '가장 많이 잊어버린 어휘', '복습이 필요 없는 어휘', '정확하게 발음하지 못한 어휘'],
            ),

            // 2. 단어 섹션
            _buildCategoryCard(
              title: '단어',
              icon: Icons.menu_book_rounded,
              color: Colors.green,
              items: ['일별 학습 단어', '가장 많이 잊어버린 어휘', '복습이 필요 없는 어휘', '정확하게 발음하지 못한 어휘'],
            ),

            // 3. 문법 섹션
            _buildCategoryCard(
              title: '문법',
              icon: Icons.psychology_rounded,
              color: Colors.orange,
              items: ['일별 학습 문법', '가장 많이 잊어버린 어휘', '복습이 필요 없는 어휘', '정확하게 발음하지 못한 어휘'],
            ),
          ],
        ),
      ),
    );
  }

  /// [함수] _buildCategoryCard
  /// 목적: 스케치 이미지처럼 카테고리 제목과 그에 따른 학습 리스트를 카드 형태로 생성합니다.
  Widget _buildCategoryCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // 둥근 모서리
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 10),
              Text(title,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(thickness: 1, color: Color(0xFFEEEEEE)), // 구분선
          const SizedBox(height: 10),

          // [리스트] 세부 항목들을 반복문을 통해 생성
          ...items.map((item) => _buildListItem(item)).toList(),
        ],
      ),
    );
  }

  /// [함수] _buildListItem
  /// 목적: 카드 내부의 개별 텍스트 항목을 렌더링합니다. (오타 수정됨: blackDE -> black87)
  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.grey.shade400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                // [수정] Colors.blackDE 대신 표준 상수인 Colors.black87 사용
                style: const TextStyle(fontSize: 14, color: Colors.black87, letterSpacing: -0.5)),
          ),
          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey.shade300),
        ],
      ),
    );
  }
}