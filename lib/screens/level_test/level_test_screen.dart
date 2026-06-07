import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/level_test_controller.dart';
import '../../design/snack_bar.dart';
import '../../models/level_test_model.dart';
import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';

class LevelTestScreen extends StatefulWidget {
  const LevelTestScreen({super.key});

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  List<dynamic> _questions = [];
  final List<String> _userAnswers = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isAnswering = false;
  String _loadingMessage = 'AI가 문제를 만드는 중입니다';
  String? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'AI가 맞춤형 문제를 생성 중입니다';
    });

    final questions = await LevelTestController.getLevelTestQuestions();
    if (!mounted) return;

    if (questions == null || questions.isEmpty) {
      setState(() => _isLoading = false);
      VipaSnackBar.show(context, '문제를 불러오지 못했습니다.', isError: true);
      return;
    }

    setState(() {
      _questions = questions.take(20).toList();
      _isLoading = false;
    });
  }

  Future<void> _submitResults() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'AI가 당신의 답변을 분석 중입니다';
    });

    final LevelTestResult? result =
        await LevelTestController.submitLevelTest(_userAnswers);

    if (!mounted) return;

    if (result == null) {
      setState(() => _isLoading = false);
      VipaSnackBar.show(context, '제출 중 오류가 발생했습니다.', isError: true);
      return;
    }

    VipaSnackBar.show(context, '테스트가 완료되었습니다!');
    Get.offAllNamed(AppRoutes.levelTestResult, arguments: result);
  }

  Future<void> _onOptionSelected(String answer) async {
    if (_isAnswering) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswering = true;
    });

    await Future.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    _userAnswers.add(answer);

    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _isAnswering = false;
      });
      return;
    }

    await _submitResults();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AuthColors.primary),
              const SizedBox(height: 24),
              Text(
                _loadingMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final currentData = _questions[_currentIndex];
    final displayQuestion = currentData is Map
        ? currentData['question']?.toString() ?? ''
        : '문제를 표시할 수 없습니다.';
    final options = currentData is Map ? (currentData['options'] ?? []) : [];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    '레벨테스트',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE5E5E5),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AuthColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 17),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 18, 12, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.24),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          displayQuestion,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...options.take(4).map((option) {
                    final text = option.toString();
                    final isSelected = _selectedAnswer == text;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: ElevatedButton(
                          onPressed: _isAnswering
                              ? null
                              : () => _onOptionSelected(text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSelected
                                ? AuthColors.primary
                                : Colors.white,
                            disabledBackgroundColor: isSelected
                                ? AuthColors.primary
                                : Colors.white,
                            foregroundColor:
                                isSelected ? Colors.white : Colors.black26,
                            disabledForegroundColor:
                                isSelected ? Colors.white : Colors.black26,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            text,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
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
