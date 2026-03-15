import 'package:flutter/material.dart';
import '../../design/card_design.dart';
import 'widgets/voice_wave.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}
class _AiScreenState extends State<AiScreen> {
  String _recognizedText = "번역할 내용을 말씀해주세요.";
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
              // 1. 상단 카드
              Expanded(
                flex: 5,
                child: cardContainer(
                  height: double.infinity, // 👈 여기에 double.infinity를 넣으세요!
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(width: 30, height: 30, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                            const SizedBox(width: 10),
                            const Text('English', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Expanded(
                          child: Center(
                            child: SingleChildScrollView(
                              child: Text(
                                _recognizedText,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                flex: 4,
                child: cardContainer(
                  height: double.infinity,
                  child: Center(
                    child: VoiceWaveView(
                      onTextRecognized: (text) {
                        setState(() => _recognizedText = text);
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