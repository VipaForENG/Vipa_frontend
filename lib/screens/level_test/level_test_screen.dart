import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/level_test_controller.dart';
import '../../design/app_colors.dart';
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
  // --- 상태 관리 변수 ---
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

  // --- API 호출 및 로직 관리 ---

  /// 문제를 서버에서 가져오는 함수
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

  /// 결과 제출 및 화면 이동 로직
  Future<void> _submitResults() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'AI가 당신의 답변을 분석 중입니다';
    });

    // 서버로 정답 데이터 전송
    final LevelTestResult? result = await LevelTestController.submitLevelTest(_userAnswers);

    if (!mounted) return;

    if (result != null) {
      VipaSnackBar.show(context, '테스트가 완료되었습니다!');
      // 데이터와 함께 결과 화면으로 이동
      Get.offAllNamed(AppRoutes.levelTestResult, arguments: result);
    } else {
      setState(() => _isLoading = false);
      VipaSnackBar.show(context, '제출 중 오류가 발생했습니다.', isError: true);
    }
  }

  /// 옵션 선택 시 실행되는 흐름 제어
  Future<void> _onOptionSelected(String answer) async {
    if (_isAnswering) return;

    setState(() {
      _selectedAnswer = answer;
      _isAnswering = true;
    });

    // 사용자 경험을 위해 살짝 지연 후 다음으로 이동
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    _userAnswers.add(answer);

    // 마지막 문제가 아니면 인덱스 증가
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _isAnswering = false;
      });
      return;
    }

    // 마지막 문제일 경우 결과 제출
    await _submitResults();
  }

  // --- UI 구현 ---

  @override
  Widget build(BuildContext context) {
    // 로딩 화면
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 62,
                  color: Colors.white,
                  alignment: Alignment.center,
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
                  child: ListView(
                      padding: const EdgeInsets.fromLTRB(14, 18, 14, 36),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(99),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 7,
                            backgroundColor: const Color(0xFFDADCE0),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AuthColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 11),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(minHeight: 98),
                        padding: const EdgeInsets.fromLTRB(12, 20, 12, 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFF2196F3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '빈칸에 들어갈 단어를 골라주세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              displayQuestion,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      ...options.take(4).map((option) {
                        final text = option.toString();
                        final isSelected = _selectedAnswer == text;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: SizedBox(
                            width: double.infinity,
                            height: 40,
                            child: ElevatedButton(
                              onPressed: _isAnswering
                                  ? null
                                  : () => _onOptionSelected(text),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: isSelected
                                    ? AuthColors.primary
                                    : const Color(0xFFF7F7F7),
                                disabledBackgroundColor: isSelected
                                    ? AuthColors.primary
                                    : const Color(0xFFF7F7F7),
                                foregroundColor: isSelected
                                    ? Colors.white
                                    : const Color(0xFFD1D1D1),
                                disabledForegroundColor: isSelected
                                    ? Colors.white
                                    : const Color(0xFFD1D1D1),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                              ),
                              child: Text(
                                text,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
