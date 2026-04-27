import 'package:flutter/material.dart';
import '../../design/card_design.dart';
import '../../controllers/ai_controller.dart'; // 컨트롤러 임포트
import 'widgets/voice_wave.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final AiController _controller = AiController();

  @override
  void initState() {
    super.initState();
    // 데이터가 변할 때마다 화면을 새로고침
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 1. AI 응답 출력 영역
              Expanded(
                flex: 5,
                child: cardContainer(
                  height: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _controller.isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          ) // 로딩 중 표시
                        : Column(
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.smart_toy,
                                    color: Colors.blueAccent,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'VIPA AI',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Expanded(
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Text(
                                      _controller.recognizedText,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              if (_controller.aiFeedback.isNotEmpty &&
                                  _controller.aiFeedback != "N/A")
                                Text(
                                  "💡 Feedback: ${_controller.aiFeedback}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // 2. 음성 입력 영역 (VoiceWaveView)
              Expanded(
                flex: 4,
                child: cardContainer(
                  height: double.infinity,
                  child: Center(
                    child: VoiceWaveView(
                      onTextRecognized: (text) {
                        _controller.sendToAi(text);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
