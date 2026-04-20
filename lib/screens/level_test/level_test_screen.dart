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
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  /// 1. 문제 불러오기
  Future<void> _fetchQuestions() async {
    final questions = await LevelTestController.getLevelTestQuestions();

    if (questions != null) {
      setState(() {
        //_questions = questions;
        _questions = questions.take(20).toList();
        _isLoading = false;
      });
    } else {
      if (mounted) {
        VipaSnackBar.show(context, '문제를 불러오지 못했습니다.');
      }
    }
  }

  /// 2. 결과 제출하기
  Future<void> _submitResults() async {
    setState(() => _isLoading = true);
    final bool success = await LevelTestController.submitLevelTest(_userAnswers);

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
      if (mounted) {
        VipaSnackBar.show(context, '제출 중 오류가 발생했습니다.');
      }
    }
  }

  void _onNextPressed() {
    final answer = _answerController.text.trim();
    if (answer.isEmpty) {
      VipaSnackBar.show(context, '답변을 입력해주세요.');
      return;
    }

    _userAnswers.add(answer);
    _answerController.clear();

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

    // 🔴 [수정 포인트] 에러 해결 로직
    // 서버에서 온 데이터가 Map일 경우 'question' 키값을 추출합니다.
    final dynamic currentData = _questions[_currentIndex];
    String displayQuestion = "";

    if (currentData is String) {
      displayQuestion = currentData;
    } else if (currentData is Map) {
      // 백엔드 gpt5.py에서 정의한 키값('question' 혹은 'text')에 맞춰야 합니다.
      displayQuestion =
          currentData['question'] ?? currentData['text'] ?? "문제를 표시할 수 없습니다.";
    }

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
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black54),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Q${_currentIndex + 1}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      displayQuestion, // 👈 추출한 문자열 표시
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _answerController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '답변을 영어로 입력하세요',
                      prefixText: '답변 : ',
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _onNextPressed(),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_currentIndex + 1} / ${_questions.length}',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 40.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _onNextPressed,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.black87, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.black87,
                  ),
                  child: Text(
                    _currentIndex < _questions.length - 1 ? '다음 문제' : '제출하기',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
