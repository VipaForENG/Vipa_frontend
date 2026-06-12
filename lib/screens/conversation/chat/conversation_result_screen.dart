import 'package:flutter/material.dart';

import '../../../routes/app_routes.dart';
import '../../history/learning_history_screen.dart';
import '../../login/auth_widgets.dart';

class ConversationResultScreen extends StatelessWidget {
  const ConversationResultScreen({super.key, required this.result});

  final Map<String, dynamic> result;

  @override
  Widget build(BuildContext context) {
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
                    '실전회화 학습완료',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(33, 32, 33, 32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
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
                        const Text(
                          '학습한 상황',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _situationTitle,
                          style: const TextStyle(
                            color: AuthColors.primary,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'AI에게 교정받은 문장',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '교정 받은 문장은 $_correctedCount개입니다.',
                          style: const TextStyle(
                            color: AuthColors.primary,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  AuthButton(
                    text: '교정문장 확인하기',
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.history,
                      arguments: HistoryDetailType.correctedSentences,
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF806B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '실전회화로 돌아가기',
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

  String get _situationTitle {
    return result['situation_title']?.toString() ??
        result['scenario_title']?.toString() ??
        '공항에서 출입국 심사 중에';
  }

  String get _correctedCount {
    return (result['corrected_count'] ?? result['correction_count'] ?? 0)
        .toString();
  }
}
