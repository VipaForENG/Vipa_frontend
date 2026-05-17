import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vipa/controllers/vocabulary_controller.dart';

class GrammarProvider extends ChangeNotifier {
  final VocabularyController _vocabularyController = Get.put(VocabularyController());

  bool isLoading = true;
  bool isChecking = false;
  
  List<dynamic> quizList = [];
  List<Map<String, dynamic>> userAnswers = [];
  
  int _currentIndex = 0;
  bool _isWrong = false;
  String? _currentHint;

  // ✨ [추가] 백엔드 최종 성적표 리포트를 화면단에 전달하기 위한 공유 레퍼런스
  Map<String, dynamic>? completionResult;

  int get currentCount => _currentIndex + 1;
  int get totalCount => quizList.isEmpty ? 10 : quizList.length;
  bool get isWrong => _isWrong;
  String? get currentHint => _currentHint;
  Map<String, dynamic>? get currentQuiz => quizList.isNotEmpty ? quizList[_currentIndex] : null;

  // 1. 퀴즈 불러오기 플로우 연동
  Future<void> fetchQuiz(int newCount, int reviewCount, int retryCount) async {
    isLoading = true;
    notifyListeners();
    
    try {
      quizList = await _vocabularyController.getQuizList(newCount, reviewCount, retryCount);
    } catch (e) {
      debugPrint("퀴즈 로드 실패: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // 2. 단일 채점 및 즉석 GPT 힌트 수신 플로우 연동
  Future<void> checkAnswer(String input, VoidCallback onCorrect, VoidCallback onFinish) async {
    if (input.trim().isEmpty || currentQuiz == null || isChecking) return;

    isChecking = true;
    notifyListeners();

    try {
      final response = await _vocabularyController.checkQuizAnswer(currentQuiz!['sentence_id'], input);
      final bool isCorrect = response['is_correct'];

      if (isCorrect) {
        _isWrong = false;
        _currentHint = null;
        userAnswers.add({"sentence_id": currentQuiz!['sentence_id'], "user_answer": input});

        if (_currentIndex < quizList.length - 1) {
          _currentIndex++;
          onCorrect();
        } else {
          await submitSession(onFinish);
        }
      } else {
        _isWrong = true;
        _currentHint = response['hint_message'];
      }
    } catch (e) {
      debugPrint("답변 체크 실패: $e");
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }

  // 3. 최종 세션 제출 플로우 연동
  Future<void> submitSession(VoidCallback onFinish) async {
    try {
      final result = await _vocabularyController.submitQuizSession(userAnswers);
      debugPrint("최종 결과: $result");
      
      // ✨ [추가] 컨트롤러가 정상 처리하여 반환한 맵 객체를 가로채 보관합니다.
      completionResult = result; 
      notifyListeners();
      
      onFinish(); 
    } catch (e) {
      debugPrint("최종 제출 실패: $e");
    }
  }
}