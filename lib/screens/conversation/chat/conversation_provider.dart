import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:async';
import '../../../api/api_service.dart';

class ConversationProvider with ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  // --- 상태 변수 ---
  bool _isRecording = false;
  bool _isAnswered = false;
  bool _isTextMode = false; // ✨ 키보드 모드 상태
  double _progress = 0.1;
  int _currentTurnIndex = 0;
  double _currentSoundLevel = 0.0;

  int? sessionId;
  int? scenarioId;
  Map<String, dynamic>? generatedScript;

  String aiEnglish = "시나리오를 생성 중입니다...";
  String aiKorean = "";
  String userTargetSentence = "";
  String feedbackKo = "";
  String correctedEn = "";
  String _userSpokenText = "";

  int _currentHintLevel = 0;
  List<String> _hints = [];
  Map<String, dynamic>? completionResult;

  int get _totalUserTurns {
    final turns = generatedScript?['turns'];
    if (turns is List && turns.isNotEmpty) {
      return (turns.length / 2).floor().clamp(1, 999);
    }
    return 1;
  }

  // --- Getters ---
  bool get isRecording => _isRecording;
  bool get isAnswered => _isAnswered;
  bool get isTextMode => _isTextMode;
  double get progress => _progress;
  String get userSpokenText => _userSpokenText;
  int get currentHintLevel => _currentHintLevel;
  List<String> get hints => _hints;
  double get dbScale =>
      (!_isRecording) ? 0.0 : (_currentSoundLevel / 10).clamp(0.0, 1.0);

  // ✨ 상태 초기화
  void reset() {
    _isRecording = false;
    _isAnswered = false;
    _isTextMode = false;
    _progress = 0.1;
    _currentTurnIndex = 0;
    _currentSoundLevel = 0.0;
    sessionId = null;
    scenarioId = null;
    generatedScript = null;
    aiEnglish = "시나리오를 생성 중입니다...";
    aiKorean = "";
    userTargetSentence = "";
    feedbackKo = "";
    correctedEn = "";
    _userSpokenText = "";
    _currentHintLevel = 0;
    _hints = [];
    completionResult = null;
    notifyListeners();
  }

  // ✨ 키보드 모드 토글
  void toggleTextMode() {
    _isTextMode = !_isTextMode;
    notifyListeners();
  }

  void setAnswered(bool value) {
    _isAnswered = value;
    notifyListeners();
  }

  void setUserSpokenText(String text) {
    _userSpokenText = text;
    notifyListeners();
  }

  // 시나리오 로드
  Future<void> initializeScenario(int subCatId) async {
    try {
      final response = await ApiService.dio.post(
        "/scenario/generate",
        data: {"sub_cat_id": subCatId},
      );
      if (response.statusCode == 200) {
        sessionId = response.data['session_id'];
        scenarioId = response.data['scenario_id'];
        generatedScript = response.data['generated_script'];
        _updateTurnUI();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ 시나리오 생성 실패: $e");
    }
  }

  // 🎙️ 음성 인식 제어
  Future<void> toggleRecording() async {
    if (_isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (_isRecording) {
            stopRecording();
          }
        }
      },
    );

    if (available) {
      _isRecording = true;
      _userSpokenText = "듣고 있어요...";
      _currentSoundLevel = 0.0;
      notifyListeners();

      await _speech.listen(
        onResult: (result) {
          _userSpokenText = result.recognizedWords;
          notifyListeners();
        },
        onSoundLevelChange: (level) {
          _currentSoundLevel = level;
          notifyListeners();
        },
        localeId: "en_US",
        // 🚨 Deprecated 경고 해결: listenMode 대신 listenOptions 사용
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.confirmation,
        ),
        pauseFor: const Duration(seconds: 3),
      );
    }
  }

  Future<void> stopRecording() async {
    if (!_isRecording) {
      return;
    }
    _isRecording = false;
    _currentSoundLevel = 0.0;
    notifyListeners();
    await _speech.stop();
    await Future.delayed(const Duration(milliseconds: 500));
    if (sessionId != null &&
        _userSpokenText.isNotEmpty &&
        _userSpokenText != "듣고 있어요...") {
      await evaluateSpeech(_userSpokenText);
    }
  }

  // 💡 🌟 수정 1: UI의 TextEditingController를 인자로 받아서 직접 값을 넣어줍니다.
  Future<void> requestHintStepByStep({TextEditingController? textController}) async {
    if (_currentHintLevel >= 4) {
      return;
    }
    _currentHintLevel++;

    if (_currentHintLevel == 1) {
      await _fetchAndAddHint(1, "초성 힌트: ");
    } else if (_currentHintLevel == 2) {
      await _fetchAndAddHint(2, "시작 문구: ");
    } else if (_currentHintLevel == 3) {
      _hints.add("⚠️ 한 번 더 누르면 정답이 입력창에 자동 완성됩니다.");
      notifyListeners();
    } else if (_currentHintLevel == 4) {
      String exactAnswer = await _fetchAndAddHint(3, "정답: ");
      
      _userSpokenText = exactAnswer;
      _isTextMode = true; 
      
      // ✨ 핵심: UI에서 넘겨받은 컨트롤러에 정답을 직접 타이핑해줍니다!
      if (textController != null) {
        textController.text = exactAnswer;
      }
      
      notifyListeners();
    }
  }

  // 📝 🌟 수정 2: 평가 API에 힌트 사용 여부를 같이 쏴줍니다.
  Future<void> evaluateSpeech(String userInput) async {
    try {
      setUserSpokenText(userInput);
      final response = await ApiService.dio.post(
        "/scenario/evaluate",
        data: {
          "session_id": sessionId,
          "scenario_id": scenarioId,
          "turn_index": _currentTurnIndex,
          "user_input": userInput,
          // ✨ 핵심: 백엔드가 "아, 이 사람은 힌트를 끝까지 다 보고 쳤구나"라고 알 수 있게 보냅니다.
          "used_hint_level": _currentHintLevel, 
        },
      );
      if (response.statusCode == 200) {
        feedbackKo = response.data['feedback_ko'] ?? "";
        correctedEn = response.data['corrected_en'] ?? "";
        await Future.delayed(const Duration(milliseconds: 1500));
        _isAnswered = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ 평가 실패: $e");
    }
  }

  // ✨ 리턴 타입을 Future<void>에서 Future<String>으로 변경하여 힌트 텍스트를 반환
  Future<String> _fetchAndAddHint(int level, String prefix) async {
    try {
      final response = await ApiService.dio.post(
        "/scenario/hint",
        data: {
          "scenario_id": scenarioId,
          "turn_index": _currentTurnIndex,
          "hint_level": level,
        },
      );
      if (response.statusCode == 200) {
        String hintText = response.data['hint_text'] ?? "";
        _hints.add("$prefix$hintText");
        notifyListeners();
        
        return hintText; // 🌟 핵심: 받아온 문장을 리턴해 줍니다.
      }
    } catch (_) {
      debugPrint("힌트 불러오기 실패");
    }
    return ""; // 에러 발생 시 빈 문자열 반환
  }

  Future<void> nextStep() async {
    _currentTurnIndex++;
    _progress = (_currentTurnIndex / _totalUserTurns).clamp(0.0, 1.0);
    _isAnswered = false;
    _isTextMode = false; // ✨ 다음 단계 시 키보드 모드 초기화
    _userSpokenText = "";
    correctedEn = "";
    _currentHintLevel = 0;
    _hints = [];

    if (_progress >= 1.0) {
      await _completeSession();
    } else {
      _updateTurnUI();
    }
    notifyListeners();
  }

  Future<void> _completeSession() async {
    try {
      final response = await ApiService.dio.post(
        "/scenario/complete",
        data: {"session_id": sessionId},
      );
      if (response.statusCode == 200) {
        completionResult = response.data;
        notifyListeners();
      }
    } catch (_) {}
  }

  void _updateTurnUI() {
    if (generatedScript != null) {
      var turns = generatedScript!['turns'];
      int aiIdx = _currentTurnIndex * 2;
      int userIdx = _currentTurnIndex * 2 + 1;
      if (aiIdx < turns.length) {
        aiEnglish = turns[aiIdx]['en'] ?? "";
        aiKorean = turns[aiIdx]['ko'] ?? "";
      }
      if (userIdx < turns.length) {
        userTargetSentence = turns[userIdx]['ko'] ?? "";
      }
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
