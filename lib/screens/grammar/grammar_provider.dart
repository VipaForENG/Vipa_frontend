import 'package:flutter/material.dart';

class GrammarProvider extends ChangeNotifier {
  // [데이터]
  final Map<String, String> quizData = {
    'level': '레벨 10',
    'category': '식당에서',
    'korean': '저희는 대부분의 손님들이 점심시간에 와요.',
    'hint': 'guest는 초청을 받아서 온 사람을 뜻합니다. 돈 내고 물건을 사는 사람은 뭐라고 부를까요?',
    'engBefore': 'We get most of our ',
    'engAfter': ' during lunchtime.',
    'answer': 'customers',
  };

  // [상태]
  int _currentCount = 0;
  bool _isWrong = false;

  // [Getter]
  int get currentCount => _currentCount;
  int get totalCount => 10;
  bool get isWrong => _isWrong;

  // [로직] 정답 확인
  void checkAnswer(String input, VoidCallback onSuccess) {
    if (input.trim().toLowerCase() == quizData['answer']) {
      if (_currentCount < totalCount) _currentCount++;
      _isWrong = false;
      onSuccess(); // 정답 시 스낵바/화면 전환 등 실행
    } else {
      _isWrong = true;
      _resetWrongStatus();
    }
    notifyListeners();
  }

  void _resetWrongStatus() {
    Future.delayed(const Duration(milliseconds: 500), () {
      _isWrong = false;
      notifyListeners();
    });
  }
}