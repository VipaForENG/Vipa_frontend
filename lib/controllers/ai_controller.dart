import 'package:flutter/material.dart';
import 'package:vipa/api/api_service.dart';

class AiController extends ChangeNotifier {
  String _recognizedText = "AI가 말하는 내용이 실시간 번역됩니다.";
  String _aiFeedback = "";
  int? _currentSessionId;
  bool _isLoading = false;

  String get recognizedText => _recognizedText;
  String get aiFeedback => _aiFeedback;
  bool get isLoading => _isLoading;

  Future<void> sendToAi(String userMessage) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.talkToAi(
        userMessage: userMessage,
        sessionId: _currentSessionId,
      );

      _currentSessionId = response['session_id'];
      _recognizedText =
          "${response['en_content']}\n\n[번역] ${response['ko_content']}";
      _aiFeedback = response['feedback'] ?? "";
    } catch (e) {
      _recognizedText = "통신 중 오류가 발생했습니다.";
      debugPrint("Controller Error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
