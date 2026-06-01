import 'package:flutter/material.dart';
import '../../design/card_design.dart';
import '../../design/app_colors.dart'; // 👈 디자인 파일 임포트

class LearningHistoryScreen extends StatelessWidget {
  const LearningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '학습내역',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '내가 학습한 내역',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            // 1. 실전회화 섹션 - cardContainer 감싸기
            cardContainer(
              child: _buildCategoryContent(
                title: '실전회화',
                icon: Icons.chat_bubble_rounded,
                color: Colors.blueAccent,
                items: [
                  '최근 대화한 상황별 세션',
                  'AI 교정 받은 문장 리스트',
                  '자주 사용한 나만의 표현',
                  '발음 피드백 다시보기',
                ],
              ),
            ),

            const SizedBox(height: 15), // 카드 사이 간격
            // 2. 오늘의 어휘 섹션 - Card_Container로 감싸기
            cardContainer(
              child: _buildCategoryContent(
                title: '오늘의 어휘',
                icon: Icons.auto_awesome_rounded,
                color: const Color(0xFF7B61FF),
                items: [
                  '일별 퀴즈 완료 기록',
                  '틀린 문장 다시 풀기 (오답)',
                  '학습한 주요 표현/구문',
                  '카테고리별 마스터 현황 (식당, 공항 등)',
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [함수] 카드 내부 콘텐츠 구성 (기존 _buildCategoryCard의 로직)
  Widget _buildCategoryContent({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20), // Card_Container 내부 여백
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(thickness: 1, color: Color(0xFFF1F1F1)),
          const SizedBox(height: 10),
          ...items.map((item) => _buildListItem(item)),
        ],
      ),
    );
  }

  Widget _buildListItem(String text) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: Colors.grey.shade300,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade300,
            ),
          ],
        ),
      ),
    );
  }
}
