import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../design/background.dart';
import '../../design/animation_design.dart';
import '../../routes/app_routes.dart';

class VocabularyResultScreen extends StatelessWidget {
  const VocabularyResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🌟 퀴즈 화면에서 넘어온 최종 결과 데이터를 받습니다.
    final Map<String, dynamic> resultData = Get.arguments ?? {};

    // 🔍 백엔드 crud/vocabulary.py 규격에 맞게 Key 명칭 매핑
    final int total = resultData['total_count'] ?? 0;
    final int correct = resultData['correct_count'] ?? 0;
    
    // ✨ [수정] 백엔드 스키마에 없는 정답률은 프론트에서 직접 계산해서 안전하게 표기!
    final double percentage = total > 0 ? (correct / total) * 100 : 0.0;
    final List results = resultData['results'] ?? [];

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // 결과창이므로 뒤로가기 방지
        title: const Text('학습 결과', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Background(
        fillLevel: 0.2, // 상단 물결 효과
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // 1. 상단 점수 카드
              FadeSlideTransition(
                delay: 0.1,
                child: _buildScoreCard(total, correct, percentage),
              ),

              const SizedBox(height: 20),

              // 2. 상세 오답 노트 리스트
              Expanded(
                child: FadeSlideTransition(
                  delay: 0.3,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15)]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("공부한 단어", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const Divider(height: 30),
                        Expanded(
                          child: ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (context, index) {
                              final item = results[index];
                              return _buildResultItem(item);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 3. 하단 홈으로 가기 버튼
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61FF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('홈으로 돌아가기', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🏆 점수 요약 카드 위젯
  Widget _buildScoreCard(int total, int correct, double percentage) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 10))]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreInfo("총 문항", "$total", Colors.grey),
          _buildScoreInfo("맞힌 개수", "$correct", Colors.blueAccent),
          _buildScoreInfo("정답률", "${percentage.toInt()}%", const Color(0xFF7B61FF)),
        ],
      ),
    );
  }

  Widget _buildScoreInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  // 📝 리스트 내 단어 아이템 위젯
  Widget _buildResultItem(dynamic item) {
    final bool isCorrect = item['is_correct'] ?? false;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
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
                // ✨ [수정] 백엔드 변수명 'target_word' 매핑
                Text(item['target_word'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                // ✨ [수정] 백엔드 변수명 'original_sentence' 매핑 (영어 예문 노출로 복습 효과 극대화)
                Text(item['original_sentence'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // 틀렸을 경우 유저가 쓴 오답 빨간색 취소선으로 표기
          if (!isCorrect)
            Text(
              item['user_answer'] ?? '', 
              style: const TextStyle(color: Colors.redAccent, fontSize: 13, decoration: TextDecoration.lineThrough)
            ),
        ],
      ),
    );
  }
}