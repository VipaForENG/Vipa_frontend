import 'package:flutter/material.dart';
import 'package:vipa/api/api_service.dart';

class AiChatMessage {
  const AiChatMessage({
    required this.text,
    required this.isUser,
    this.translation = '',
  });

  final String text;
  final String translation;
  final bool isUser;
}

class AiController extends ChangeNotifier {
  final List<AiChatMessage> _messages = [
    const AiChatMessage(
      text: "Hello! I'm VIPA AI.",
      translation: '안녕하세요. VIPA AI입니다.',
      isUser: false,
    ),
  ];

  int _totalEnergy = 0;
  bool _isLimitReached = false;
  int? _currentSessionId;
  bool _isLoading = false;

  List<AiChatMessage> get messages => List.unmodifiable(_messages);
  int get totalEnergy => _totalEnergy;
  bool get isLimitReached => _isLimitReached;
  bool get isLoading => _isLoading;

  static Future<Map<String, dynamic>> talkToAi({
    required String userMessage,
    int? sessionId,
  }) async {
    final response = await ApiService.dio.post(
      '/chat/talk',
      data: {'user_message': userMessage, 'session_id': sessionId},
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    }
    throw Exception('서버 응답 오류: ${response.statusCode}');
  }

  Future<void> sendToAi(String userMessage) async {
    final message = userMessage.trim();
    if (message.isEmpty || _isLoading) return;

    _messages.add(AiChatMessage(text: message, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      final response = await talkToAi(
        userMessage: message,
        sessionId: _currentSessionId,
      );

      final english = response['en_content']?.toString() ?? '';
      final korean = response['ko_content']?.toString() ?? '';
      final energy = response['earned_energy'];

      if (english.isNotEmpty || korean.isNotEmpty) {
        _messages.add(
          AiChatMessage(
            text: english.isEmpty ? korean : english,
            translation: english.isEmpty ? '' : korean,
            isUser: false,
          ),
        );
      }
      if (energy is num) _totalEnergy += energy.toInt();
      _isLimitReached = response['is_limit_reached'] == true;
      if (response['session_id'] is int) {
        _currentSessionId = response['session_id'] as int;
      }
    } catch (error) {
      _messages.add(
        const AiChatMessage(
          text: 'Connection lost.',
          translation: '서버와 연결할 수 없습니다.',
          isUser: false,
        ),
      );
      debugPrint('AI controller error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
