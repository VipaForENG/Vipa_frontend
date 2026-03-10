import 'package:flutter/material.dart';

/// [클래스] VocabularyScreen
/// 목적: 더미 데이터를 사용하여 단어의 정의를 보고 영어 단어를 맞추는 퀴즈 화면.
class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  // [더미 데이터] 학습용 단어 목록
  final List<Map<String, String>> _quizData = [
    {'word': 'frustrated', 'definition': '좌절감을 느끼는, 불만스러워하는'},
    {'word': 'dilemma', 'definition': '딜레마, 진퇴양난'},
    {'word': 'inspire', 'definition': '영감을 주다, 고무하다'},
  ];

  int _currentIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  String _message = "";

  /// [함수] _checkAnswer
  /// 목적: 사용자가 입력한 단어가 정답인지 확인합니다.
  void _checkAnswer() {
    setState(() {
      if (_answerController.text.trim().toLowerCase() == _quizData[_currentIndex]['word']) {
        _message = "정답입니다! 🎉";
      } else {
        _message = "틀렸어요. 다시 생각해보세요!";
      }
    });
  }

  /// [함수] _nextQuestion
  /// 목적: 다음 퀴즈로 넘어갑니다.
  void _nextQuestion() {
    setState(() {
      if (_currentIndex < _quizData.length - 1) {
        _currentIndex++;
        _answerController.clear();
        _message = "";
      } else {
        _message = "모든 퀴즈를 완료했습니다!";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentQuiz = _quizData[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: const Text('단어 맞추기 퀴즈')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // [위젯] 문제 표시 (정의 출력)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
              child: Text(
                "정의: ${currentQuiz['definition']}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),

            // [위젯] 입력창
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(labelText: "영단어를 입력하세요"),
            ),
            const SizedBox(height: 20),

            // [위젯] 버튼 영역
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: _checkAnswer, child: const Text("정답 확인")),
                ElevatedButton(onPressed: _nextQuestion, child: const Text("다음 문제")),
              ],
            ),
            const SizedBox(height: 20),
            Text(_message, style: TextStyle(fontSize: 16, color: _message.contains("정답") ? Colors.blue : Colors.red)),
          ],
        ),
      ),
    );
  }
}