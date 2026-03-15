import 'package:flutter/material.dart';

class ConversationProvider extends ChangeNotifier {
  // 상태 관리
  bool _isAnswered = false;
  double _progress = 0.3; // 0.0 ~ 1.0

  // 데이터 (나중에 API 연동)
  final String aiEnglish = "Hello. Please come in.";
  final String aiKorean = "안녕하세요. 들어오세요.";
  final String userTargetSentence = "안녕하세요, 선생님. 검사 결과지 가지고 왔어요.";

  // Getter
  bool get isAnswered => _isAnswered;
  double get progress => _progress;

  // 비즈니스 로직
  void setAnswered(bool value) {
    _isAnswered = value;
    notifyListeners();
  }

  void nextStep() {
    _isAnswered = false;
    _progress += 0.1;
    if (_progress > 1.0) _progress = 1.0;
    notifyListeners();
  }
}