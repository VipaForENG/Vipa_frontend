import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';

class VocabularyResultScreen extends StatelessWidget {
  const VocabularyResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> resultData = Get.arguments ?? {};
    final int total = resultData['total_count'] ?? 0;
    final int correct = resultData['correct_count'] ?? 0;
    final double percentage = total > 0 ? (correct / total) * 100 : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Column(
                children: [
                  const Text(
                    '오늘의 어휘 학습완료',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(33, 40, 33, 40),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ResultLine(
                          title: '총 문항',
                          subtitle: '모든 문제의 개수는 $total개입니다.',
                        ),
                        const SizedBox(height: 25),
                        _ResultLine(
                          title: '정답 개수',
                          subtitle: '맞힌 개수는 $correct개 입니다.',
                        ),
                        const SizedBox(height: 25),
                        _ResultLine(
                          title: '정답률',
                          subtitle: '총 정답률은 ${percentage.toInt()}% 입니다.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  AuthButton(
                    text: '틀린 어휘 확인하기',
                    onPressed: () {},
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
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '오늘의 어휘로 돌아가기',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultLine extends StatelessWidget {
  const _ResultLine({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            color: AuthColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
