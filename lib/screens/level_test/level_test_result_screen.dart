import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/level_test_model.dart';
import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';

class LevelTestResultScreen extends StatelessWidget {
  const LevelTestResultScreen({super.key, required this.result});

  final LevelTestResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 30),
              child: Column(
                children: [
                  const Text(
                    '레벨테스트',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 31),
                  _ResultCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 38),
                      child: Column(
                        children: [
                          const Text(
                            '예상 CEFR 레벨',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            result.cefrLevel,
                            style: const TextStyle(
                              color: AuthColors.primary,
                              fontSize: 68,
                              fontWeight: FontWeight.w900,
                              height: 0.95,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ResultCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(33, 25, 33, 23),
                      child: Column(
                        children: [
                          const Text(
                            '영역별 역량 점수',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 21),
                          _ScoreBar(label: '문법의 베이스', score: result.grammarScore),
                          const SizedBox(height: 17),
                          _ScoreBar(label: '어휘의 섬세함', score: result.vocabularyScore),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ResultCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(31, 20, 31, 20),
                      child: Column(
                        children: [
                          const Text(
                            '나의 약점',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 9,
                            runSpacing: 8,
                            alignment: WrapAlignment.center,
                            children: _weaknessTags
                                .map((tag) => _WeaknessChip(text: tag))
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ResultCard(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 19, 20, 20),
                      child: Column(
                        children: [
                          const Text(
                            'AI 상세 피드백',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _feedback,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              height: 1.25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 23),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Get.offAllNamed(AppRoutes.home),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuthColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '홈',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<String> get _weaknessTags {
    if (result.weaknessTags.isNotEmpty) {
      return result.weaknessTags.take(4).toList();
    }
    return const ['시제훈련', '동사활용법', '어휘부족', '문장구조훈련'];
  }

  String get _feedback {
    final text = result.detailedFeedback.trim();
    if (text.isNotEmpty) return text;
    return '기초 문법과 빈칸 추론은 비교적 안정적이지만, 시제 일치와 동사 형태 선택에서 실수가 보입니다. 특히 3인칭 단수, 현재완료, 과거 시제 구분 그리고 문맥에 맞는 동사 선택에서 흔들림이 있습니다. 어휘는 일상적 수준은 이미 일부 갖추고 있지만, 익숙하지 않은 단어의 뜻을 유추하는 문맥에서는 정확도가 떨어집니다. 전반적으로 A2를 넘어 B1 초입 수준이며, B2 수준의 정교한 문장 독해는 아직 부족합니다.';
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ScoreBar extends StatelessWidget {
  const _ScoreBar({required this.label, required this.score});

  final String label;
  final int score;

  @override
  Widget build(BuildContext context) {
    final normalizedScore = (score / 100).clamp(0.0, 1.0).toDouble();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '$score점',
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: normalizedScore,
            minHeight: 6,
            backgroundColor: const Color(0xFFE2E2E2),
            valueColor: const AlwaysStoppedAnimation<Color>(AuthColors.primary),
          ),
        ),
      ],
    );
  }
}

class _WeaknessChip extends StatelessWidget {
  const _WeaknessChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF806B),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
