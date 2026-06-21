import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../history/learning_history_screen.dart';
import '../login/auth_widgets.dart';

class VocabularyResultScreen extends StatelessWidget {
  const VocabularyResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> resultData = Get.arguments ?? {};
    final int total = _asInt(resultData['total_count']);
    final int correct = _asInt(resultData['correct_count']);
    final int percentage = total > 0 ? ((correct / total) * 100).round() : 0;

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
                  height: 62,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: const Text(
                    '오늘의 어휘 학습완료',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(52, 48, 32, 50),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ResultText(
                          title: '총 문항',
                          description: '모든 문제의 개수는 $total개입니다.',
                        ),
                        const SizedBox(height: 25),
                        _ResultText(
                          title: '정답 개수',
                          description: '만점님의 정답 개수는 $correct개 입니다.',
                        ),
                        const SizedBox(height: 25),
                        _ResultText(
                          title: '정답률',
                          description: '총 정답률은 $percentage% 입니다.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 29),
                _ResultButton(
                  text: '틀린 어휘 확인하기',
                  color: AuthColors.primary,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.history,
                    arguments: HistoryDetailType.wrongWords,
                  ),
                ),
                const SizedBox(height: 11),
                _ResultButton(
                  text: '홈으로 돌아가기',
                  color: const Color(0xFFFF806B),
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (_) => false,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _ResultText extends StatelessWidget {
  const _ResultText({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 27,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            color: AuthColors.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ResultButton extends StatelessWidget {
  const _ResultButton({
    required this.text,
    required this.color,
    required this.onPressed,
  });

  final String text;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              maxLines: 1,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}
