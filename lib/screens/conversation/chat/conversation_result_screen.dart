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
                    '실전회화 학습완료',
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
                    padding: const EdgeInsets.fromLTRB(52, 29, 30, 30),
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
                        const Text(
                          '학습한 상황',
                          style: TextStyle(
                            fontSize: 27,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          _situationTitle,
                          style: const TextStyle(
                            color: AuthColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          'AI에게 교정받은 문장',
                          style: TextStyle(
                            fontSize: 27,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '교정 받은 문장은 $_correctedCount개 입니다.',
                          style: const TextStyle(
                            color: AuthColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                _ResultButton(
                  text: '교정문장 확인하기',
                  color: AuthColors.primary,
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.history,
                    arguments: HistoryDetailType.correctedSentences,
                  ),
                ),
                const SizedBox(height: 11),
                _ResultButton(
                  text: '실전회화로 돌아가기',
                  color: const Color(0xFFFF806B),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
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
