import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../Design/snack_bar.dart';
import '../../controllers/level_test_controller.dart';

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
  String? _selectedAnswer; // 선택된 답변 저장용 변수

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
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
    setState(() => _isLoading = true);
    final bool success = await LevelTestController.submitLevelTest(
      _userAnswers,
    );

    if (success) {
      if (!mounted) return;
      VipaSnackBar.show(context, '테스트가 완료되었습니다!');
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black87)),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'CEFR 레벨 테스트',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
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
                separatorBuilder: (_, _) => const SizedBox(height: 10),
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
