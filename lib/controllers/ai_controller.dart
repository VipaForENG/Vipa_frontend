import 'package:flutter/material.dart';
import 'package:vipa/api/api_service.dart'; // 실제 API 경로에 맞게 확인해주세요

class AiController extends ChangeNotifier {
  // 🔥 1. 상태 변수 선언 (에러의 원인이었던 변수들 추가)
  String _aiEnText = "Hello! I'm VIPA AI.";
  String _aiKoText = "안녕하세요! VIPA AI입니다.";
  String _aiFeedback = "";
  int _totalEnergy = 0;           // ⚡ 누적 에너지
  bool _isLimitReached = false;   // 🚫 제한 도달 여부
  int? _currentSessionId;
  bool _isLoading = false;

  // 🔥 2. Getter 선언 (UI에서 변수를 읽어갈 수 있도록 통로 개방)
  String get aiEnText => _aiEnText;
  String get aiKoText => _aiKoText;
  String get aiFeedback => _aiFeedback;
  int get totalEnergy => _totalEnergy;
  bool get isLimitReached => _isLimitReached;
  bool get isLoading => _isLoading;


 static Future<Map<String, dynamic>> talkToAi({
    required String userMessage,
    int? sessionId,
  }) async {
    try {
      final response = await ApiService.dio.post(
        "/chat/talk",
        data: {"user_message": userMessage, "session_id": sessionId},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("서버 응답 오류: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ApiService Error: $e");
      rethrow;
    }
  }

  // 3. 메인 비즈니스 로직
  Future<void> sendToAi(String userMessage) async {
    if (userMessage.isEmpty || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // API 호출
      final response = await talkToAi(
        userMessage: userMessage,
        sessionId: _currentSessionId, // 요청 시에는 기존 세션 ID 전송
      );

      // API 응답 구조 분해 할당 (패턴 매칭)
      if (response case {
        'en_content': String en,
        'ko_content': String ko,
        'feedback': String fb,
        'earned_energy': int energy,
        'is_limit_reached': bool limit,
      }) {
        _aiEnText = en;
        _aiKoText = ko;
        _aiFeedback = fb;
        _totalEnergy += energy; // ⚡ 변수 업데이트
        _isLimitReached = limit; // 🚫 변수 업데이트
      } else {
        debugPrint("🚨 서버 응답 규격이 맞지 않습니다: $response");
      }
      
    } catch (e) {
      _aiEnText = "Connection lost.";
      _aiKoText = "서버와 연결할 수 없습니다.";
      debugPrint("Controller Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}