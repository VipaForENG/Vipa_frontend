import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

import '../../../design/app_colors.dart';

class VoiceWaveView extends StatefulWidget {
  final Function(String) onTextRecognized;
  const VoiceWaveView({super.key, required this.onTextRecognized});

  @override
  State<VoiceWaveView> createState() => _VoiceWaveViewState();
}

class _VoiceWaveViewState extends State<VoiceWaveView> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false; // 사용자 의도 (버튼 클릭 상태)
  bool _speechEnabled = false;
  List<double> _waveHeights = List.generate(15, (index) => 10.0);
  double _lastSoundLevel = 0.0;
  Timer? _waveTimer;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize(
      onStatus: (s) {
        if (_isListening && (s == 'done' || s == 'notListening')) {
          _relisten();
        }
      },
      onError: (_) {},
    );
  }

  void _relisten() async {
    if (_isListening) {
      await _speech.listen(
        onResult: (val) => widget.onTextRecognized(val.recognizedWords),
        onSoundLevelChange: (level) => _lastSoundLevel = level,
        listenOptions: stt.SpeechListenOptions(
          localeId: 'en_US',
          listenMode: stt.ListenMode.dictation,
          cancelOnError: false,
          partialResults: true,
        ),
      );
    }
  }

  void _startWaveAnimation() {
    _waveTimer?.cancel();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 80), (timer) {
      if (!mounted || !_isListening) return;
      setState(() {
        double level = _lastSoundLevel.abs();
        double newHeight = 10 + (level * 6) + Random().nextDouble() * 10;
        _waveHeights.removeAt(0);
        _waveHeights.add(newHeight.clamp(10, 80));
      });
    });
  }

  Future<void> _toggleListen() async {
    if (!_isListening) {
      var status = await Permission.microphone.request();
      if (!status.isGranted) return;
      if (_speechEnabled || await _speech.initialize()) {
        setState(() => _isListening = true);
        _startWaveAnimation();
        _relisten(); // 인식 시작
      }
    } else {
      setState(() => _isListening = false);
      await _speech.stop();
      _waveTimer?.cancel();
      setState(() {
        _waveHeights = List.generate(15, (index) => 10.0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 150.0;
        final compact = maxHeight < 145;
        final waveBoxHeight = compact ? 56.0 : 80.0;
        final buttonPadding = compact ? 12.0 : 15.0;
        final iconSize = compact ? 30.0 : 35.0;
        final gap = compact ? 8.0 : 15.0;
        final waveMaxHeight = compact ? 54.0 : 80.0;

        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: waveBoxHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _waveHeights
                      .map(
                        (h) => AnimatedContainer(
                          duration: const Duration(milliseconds: 80),
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 5,
                          height: h.clamp(10, waveMaxHeight).toDouble(),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: gap),
              ElevatedButton(
                onPressed: _toggleListen,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: EdgeInsets.all(buttonPadding),
                  backgroundColor: _isListening
                      ? AppColors.primary
                      : AppColors.accent,
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  size: iconSize,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _waveTimer?.cancel();
    _speech.stop();
    super.dispose();
  }
}
