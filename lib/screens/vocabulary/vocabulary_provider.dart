import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vipa/controllers/vocabulary_controller.dart';

class GrammarProvider extends ChangeNotifier {
  final VocabularyController _vocabularyController = Get.put(VocabularyController());

  bool isLoading = true;
  bool isChecking = false;
  bool isBookmarking = false;
  
  List<dynamic> quizList = [];
  List<Map<String, dynamic>> userAnswers = [];
  
  int _currentIndex = 0;
  bool _isWrong = false;
  String? _currentHint;

  // ✨ [신규 추가] 투 스트라이크 아웃 제어 상태 변수
  int currentAttempt = 1;      // 현재 문제 시도 횟수
  bool canRetry = true;        // 재시도 가능 여부
  String? targetWord;          // 백엔드가 알려준 진짜 정답
  
  // ✨ 백엔드 최종 성적표 리포트를 화면단에 전달하기 위한 공유 레퍼런스
  Map<String, dynamic>? completionResult;

  // ✨ [신규 추가] 이번 퀴즈 세션에서 즐겨찾기한 단어들의 ID를 모아두는 Set
  final Set<int> _bookmarkedIds = {};


  bool get isCurrentBookmarked {
    if (currentQuiz == null) return false;
    final id = int.tryParse(currentQuiz!['sentence_id'].toString());
    return id != null && _bookmarkedIds.contains(id);
  }
  int get currentCount => _currentIndex + 1;
  int get totalCount => quizList.isEmpty ? 10 : quizList.length;
  bool get isWrong => _isWrong;
  String? get currentHint => _currentHint;
  Map<String, dynamic>? get currentQuiz => quizList.isNotEmpty ? quizList[_currentIndex] : null;

  // 턴 전환 시 상태 초기화
  void _resetTurnStats() {
    _isWrong = false;
    _currentHint = null;
    currentAttempt = 1;
    canRetry = true;
    targetWord = null;
  }

  // 1. 퀴즈 불러오기 플로우 연동
  Future<void> fetchQuiz(int newCount, int reviewCount, int retryCount) async {
    isLoading = true;
    _currentIndex = 0;
    quizList = [];
    _resetTurnStats(); // 시작 시 초기화
    userAnswers.clear();
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
  Future<void> checkAnswer(String input, VoidCallback onCorrect, VoidCallback onFinish, VoidCallback onFailedComplete) async {
    if (input.trim().isEmpty || currentQuiz == null || isChecking) return;

    isChecking = true;
    notifyListeners();

    try {
      // 🚨 주의: 컨트롤러에 currentAttempt도 함께 넘겨주도록 파라미터를 꼭 추가해 주세요!
      final response = await _vocabularyController.checkQuizAnswer(
        currentQuiz!['sentence_id'], 
        input,
        currentAttempt // 🔥 새로 추가된 시도 횟수 전달
      );
      
      final bool isCorrect = response['is_correct'];

      if (isCorrect) {
        userAnswers.add({"sentence_id": currentQuiz!['sentence_id'], "user_answer": input});
        _moveToNext(onCorrect, onFinish);
      } else {
        _isWrong = true;
        _currentHint = response['hint_message'];
        canRetry = response['can_retry'] ?? true; // 백엔드가 안 주면 기본 기회 부여
        targetWord = response['target_word'];     // 오답 시 정답 수신

        if (canRetry) {
          currentAttempt++; // 1회차 오답이면 다음 시도는 2회차로
        } else {
          // 기회 완전 소진: 틀린 답안 그대로 저장하고 UI에 알림
          userAnswers.add({"sentence_id": currentQuiz!['sentence_id'], "user_answer": input});
          onFailedComplete();
        }
      }
    } catch (e) {
      debugPrint("답변 체크 실패: $e");
    } finally {
      isChecking = false;
      notifyListeners();
    }
  }

  // ✨ [신규 추가] 오답으로 기회가 끝난 후 강제로 다음 문제로 넘기는 로직
  void forceNextQuestion(VoidCallback onCorrect, VoidCallback onFinish) {
    _moveToNext(onCorrect, onFinish);
  }

  // 내부 공통 함수: 다음 문제로 이동 또는 최종 제출
  Future<void> _moveToNext(VoidCallback onCorrect, VoidCallback onFinish) async {
    if (_currentIndex < quizList.length - 1) {
      _currentIndex++;
      _resetTurnStats();
      notifyListeners();

      onCorrect();
    } else {
      await submitSession(onFinish);
    }
  }

  // 3. 최종 세션 제출 플로우 연동
  Future<void> submitSession(VoidCallback onFinish) async {
    try {
      final result = await _vocabularyController.submitQuizSession(userAnswers);
      completionResult = result; 
      notifyListeners();
      onFinish(); 
    } catch (e) {
      debugPrint("최종 제출 실패: $e");
    }
  }

  // ✨ [신규 추가] 즐겨찾기 토글 로직 (낙관적 UI 업데이트 적용)
  Future<void> toggleBookmark() async {
    if (currentQuiz == null || isBookmarking) return;
    
    final int vocabId = int.parse(currentQuiz!['sentence_id'].toString());
    final bool currentState = _bookmarkedIds.contains(vocabId);
    final bool newState = !currentState;

    isBookmarking = true;
    if (newState) {
      _bookmarkedIds.add(vocabId);
    } else {
      _bookmarkedIds.remove(vocabId);
    }
    notifyListeners(); 

    try {
      // 2. 백엔드 API 호출
      await _vocabularyController.toggleBookmark(vocabId, newState);
    } catch (e) {
      debugPrint("즐겨찾기 토글 실패: $e");
      if (currentState) {
        _bookmarkedIds.add(vocabId);
      } else {
        _bookmarkedIds.remove(vocabId);
      }
    } finally {
      isBookmarking = false;
      notifyListeners();
    }
  }
}
