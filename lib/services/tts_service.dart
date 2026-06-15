// services/tts_service.dart
import 'package:flutter/foundation.dart'; // debugPrint용
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();

  Future<void> init() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    debugPrint('TTS: 초기화 완료'); // 로그 확인
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    debugPrint('TTS: 다음 문장을 읽습니다 -> $text'); // 🌟 로그가 찍히는지 꼭 확인하세요!
    await _tts.stop();
    await _tts.speak(text);
  }
}