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
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 54,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: const Text(
                    '레벨테스트',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    child: Column(
                      children: [
                        _ResultCard(
                          minHeight: 170,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '예상 CEFR 레벨',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result.cefrLevel,
                                style: const TextStyle(
                                  color: AuthColors.primary,
                                  fontSize: 66,
                                  height: 1,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ResultCard(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(25, 18, 25, 18),
                            child: Column(
                              children: [
                                const Text(
                                  '영역별 역량 점수',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                _ScoreBar(
                                  label: '문법의 베이스',
                                  score: result.grammarScore,
                                ),
                                const SizedBox(height: 10),
                                _ScoreBar(
                                  label: '어휘의 섬세함',
                                  score: result.vocabularyScore,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _ResultCard(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
                            child: Column(
                              children: [
                                const Text(
                                  '나의 약점',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 13),
                                Wrap(
                                  spacing: 8,
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
                        const SizedBox(height: 10),
                        _ResultCard(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                            child: Column(
                              children: [
                                const Text(
                                  'AI 상세 피드백',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _feedback,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.35,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: 198,
                          height: 36,
                          child: ElevatedButton(
                            onPressed: () => Get.offAllNamed(AppRoutes.home),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AuthColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7),
                              ),
                            ),
                            child: const Text(
                              '홈',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
    return const ['시제관계', '동사활용법', '어휘력', '문장구조연결'];
  }

  String get _feedback {
    final feedback = result.detailedFeedback.trim();
    if (feedback.isNotEmpty) return feedback;
    return '기초 문법과 빈칸 추론 비교는 안정적이지만, 시제 일치와 동사 형태 선택에서 실수가 보입니다. '
        '다양한 문장을 반복해서 연습하면 더욱 자연스럽고 정확한 표현을 사용할 수 있습니다.';
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.child, this.minHeight});

  final Widget child;
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight ?? 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 4,
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
    final value = (score / 100).clamp(0.0, 1.0).toDouble();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
            Text(
              '$score점',
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 5,
            backgroundColor: const Color(0xFFD9D9D9),
            valueColor: const AlwaysStoppedAnimation<Color>(
              Color(0xFFFF806B),
            ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF806B),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
