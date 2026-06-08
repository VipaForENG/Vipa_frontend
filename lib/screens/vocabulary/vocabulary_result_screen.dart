import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../design/app_colors.dart';
import '../../design/background.dart';

class VocabularyResultScreen extends StatelessWidget {
  const VocabularyResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 결과 데이터 처리
    final Map<String, dynamic> resultData = Get.arguments ?? {};
    final int total = resultData['total_count'] ?? 0;
    final int correct = resultData['correct_count'] ?? 0;
    final List<dynamic> results = resultData['results'] ?? [];
    
    // 정답률 계산
    final double percentage = total > 0 ? (correct / total) * 100 : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '학습 결과',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Background(
        fillLevel: 0.2,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // 1. 점수 요약 카드
              _buildScoreCard(total, correct, percentage),

              const SizedBox(height: 20),

              // 2. 상세 결과 리스트 (화이트 컨테이너 UI 적용)
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "학습 상세 내역",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const Divider(height: 30),
                      Expanded(
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: results.length,
                          itemBuilder: (context, index) {
                            return _buildResultItem(results[index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // 3. 버튼 영역
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: 틀린 어휘 복습 로직 연결
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          '틀린 어휘 확인하기',
                          style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.home,
                          (route) => false,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF806B),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '오늘의 어휘로 돌아가기',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 점수 요약 카드
  Widget _buildScoreCard(int total, int correct, double percentage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreInfo("총 문항", "$total", Colors.black87),
          _buildScoreInfo("정답", "$correct", Colors.blue),
          _buildScoreInfo("정답률", "${percentage.toInt()}%", AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildScoreInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
      ],
    );
  }

  // 리스트 아이템
  Widget _buildResultItem(dynamic item) {
    final bool isCorrect = item['is_correct'] ?? false;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isCorrect ? Colors.blue.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCorrect ? Icons.check : Icons.close,
              color: isCorrect ? Colors.blue : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['target_word'] ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  item['original_sentence'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!isCorrect)
            Text(
              item['user_answer'] ?? '',
              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 13,
                decoration: TextDecoration.lineThrough,
              ),
            ),
        ],
      ),
    );
  }
}