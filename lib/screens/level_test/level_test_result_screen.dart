import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/level_test_model.dart';
import '../../routes/app_routes.dart';
import '../../design/app_colors.dart';

// [재사용] 공통 디자인 위젯 임포트
import '../../../design/card_design.dart';
import '../../../design/button_design.dart';

class LevelTestResultScreen extends StatelessWidget {
  final LevelTestResult result;

  const LevelTestResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // 전체 배경색
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'AI 레벨 분석 결과',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. 메인 레벨 표시 카드 (cardContainer 재사용)
            cardContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Column(
                  children: [
                    const Text(
                      '당신의 예상 CEFR 레벨',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.cefrLevel,
                      style: const TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w900,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '정답률: ${result.correctAnswersCount}/20',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 영역별 점수 분석 카드 (cardContainer 재사용)
            cardContainer(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '영역별 역량 지수',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildScoreBar(
                      '문법 지수',
                      result.grammarScore,
                      Colors.orangeAccent,
                    ),
                    const SizedBox(height: 16),
                    _buildScoreBar(
                      '어휘 정밀도',
                      result.vocabularyScore,
                      Colors.greenAccent,
                    ),
                  ],
                ),
              ),
            ),

            // 3. 약점 키워드 및 AI 피드백 카드 (cardContainer 재사용)
            cardContainer(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '중점 보완 키워드',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: result.weaknessTags
                          .map((tag) => _buildTagChip(tag))
                          .toList(),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Color(0xFFEDF0F3)),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: Colors.blueAccent,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI 상세 피드백',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      result.detailedFeedback,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.6,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. 하단 액션 버튼 (vipaPrimaryButton 재사용)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20.0,
              ),
              child: SizedBox(
                width: double.infinity, // 버튼을 가로로 꽉 채웁니다.
                child: vipaPrimaryButton(
                  title: '홈으로 이동',
                  icon: Icons.home_rounded,
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- 내부 보조 위젯 ---

  Widget _buildScoreBar(String label, int score, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
            Text(
              '$score점',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: score / 100,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F3F5),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFEDF0F3)),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF636E72),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
