import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../Design/snack_bar.dart';
import '../../controllers/level_test_controller.dart';
import '../../models/level_test_model.dart';
import 'package:get/get.dart';
import '../../design/app_colors.dart';

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
  String _loadingMessage = 'AI가 문제를 만드는 중입니다';
  String? _selectedAnswer; // 선택된 답변 저장용 변수

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
    if (questions != null) {
      setState(() {
        _questions = questions.take(20).toList();
        _isLoading = false;
      });
    } else {
      if (mounted) VipaSnackBar.show(context, '문제를 불러오지 못했습니다.');
    }
  }

  Future<void> _submitResults() async {
    setState(() {
      _isLoading = true;
      _loadingMessage = 'AI가 당신의 답변을 정밀 분석하여\n상세 결과를 생성하고 있습니다';
    });

    // 1. 서버에 답변 제출 후 결과(LevelTestResult) 받기
    final LevelTestResult? result = await LevelTestController.submitLevelTest(
      _userAnswers,
    );

    if (result != null) {
      if (!mounted) return;
      VipaSnackBar.show(context, '테스트가 완료되었습니다!');

      // 2. 🔥 GetX 전용 명령어로 이동 (arguments에 데이터를 실어 보냄)
      // offAllNamed는 이전의 모든 스택(테스트 화면 등)을 비우고 이동합니다.
      Get.offAllNamed(AppRoutes.levelTestResult, arguments: result);
    } else {
      setState(() => _isLoading = false);
      if (mounted) VipaSnackBar.show(context, '제출 중 오류가 발생했습니다.');
    }
  }

  void _onOptionSelected(String answer) {
    setState(() {
      _selectedAnswer = answer;
    });
  }

  void _onNextPressed() {
    if (_selectedAnswer == null) {
      VipaSnackBar.show(context, '답변을 선택해주세요.');
      return;
    }

    _userAnswers.add(_selectedAnswer!);
    _selectedAnswer = null; // 다음 문제 위해 초기화

    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _submitResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.black87,
                strokeWidth: 3,
              ),
              const SizedBox(height: 30),

              // 🔥 [수정] 하드코딩된 'AI가 맞춤형 문제를 생성 중입니다' 대신 변수 사용
              Text(
                _loadingMessage,
                textAlign: TextAlign.center, // 두 줄 이상일 때를 대비해 중앙 정렬
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // [팁] 메인 메시지가 바뀔 때 서브 문구도 적절히 어울리도록 수정
              Text(
                _loadingMessage.contains('분석')
                    ? '잠시만 기다려주세요.\n당신을 위한 맞춤 학습 리포트를 작성 중입니다.'
                    : '잠시만 기다려주세요.\n당신의 실력에 딱 맞는 문제를 준비하고 있어요.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final dynamic currentData = _questions[_currentIndex];
    // 서버 데이터 형식에 맞춰 수정 (예: {'question': '...', 'options': ['A', 'B', 'C', 'D']})
    String displayQuestion = currentData is Map
        ? currentData['question'] ?? ""
        : "문제를 표시할 수 없습니다.";
    List<dynamic> options = currentData is Map
        ? (currentData['options'] ?? [])
        : [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'CEFR 레벨 테스트',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // 질문 영역
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Q${_currentIndex + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    displayQuestion,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // 객관식 보기 버튼들
            Expanded(
              child: ListView.separated(
                itemCount: options.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  String option = options[index].toString();
                  bool isSelected = _selectedAnswer == option;
                  return OutlinedButton(
                    onPressed: () => _onOptionSelected(option),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.black87
                          : Colors.white,
                      side: BorderSide(
                        color: isSelected ? Colors.black87 : Colors.black12,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  );
                },
              ),
            ),
            // 하단 버튼
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _onNextPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? '다음 문제' : '제출하기',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
