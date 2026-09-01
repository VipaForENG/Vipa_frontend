// services/tts_service.dart
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  int _playbackId = 0;

  Future<void> init() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.awaitSpeakCompletion(true);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    final playbackId = ++_playbackId;
    await _tts.stop();
    if (playbackId != _playbackId) return;
    await _tts.speak(text);
  }

  Future<void> speakWithBlankPause(
    String maskedText, {
    Duration pause = const Duration(milliseconds: 700),
  }) async {
    final parts = maskedText.split('____');
    final playbackId = ++_playbackId;
    await _tts.stop();

    for (var index = 0; index < parts.length; index++) {
      if (playbackId != _playbackId) return;
      final text = parts[index].trim();
      if (text.isNotEmpty) {
        await _tts.speak(text);
      }
      if (index < parts.length - 1) {
        await Future<void>.delayed(pause);
        if (playbackId != _playbackId) return;
      }
    }
  }

  Future<void> stop() async {
    _playbackId++;
    await _tts.stop();
  }
}
