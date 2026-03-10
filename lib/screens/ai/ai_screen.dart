import 'package:flutter/material.dart';

/// [클래스] AiScreen
/// 목적: AI와 함께하는 쉐도잉 학습 페이지. TTS 로그와 음성 분석 기능을 제공합니다.
class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  // [변수] isRecording: 현재 음성 녹음(발음 분석) 중인지 확인하는 플래그
  bool isRecording = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('AI 쉐도잉 체크', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // [위젯] 상단 TTS 텍스트 및 로그 표시 영역
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView(
                children: const [
                  Text("AI 쉐도잉 문장: Hello, how are you today?", style: TextStyle(fontSize: 16)),
                  Divider(),
                  Text("-> TTS text log:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("User: (사용자 발음 로그가 이곳에 출력됩니다...)"),
                ],
              ),
            ),
          ),

          // [위젯] 하단 마이크 컨트롤 영역
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Column(
              children: [
                Text(isRecording ? "분석 중입니다..." : "마이크를 눌러 시작하세요",
                    style: const TextStyle(color: Colors.blueAccent)),
                const SizedBox(height: 20),
                // [위젯] 마이크 버튼 (누르면 녹음/분석 시작)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isRecording = !isRecording;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording ? Colors.redAccent : Colors.blueAccent,
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                    ),
                    child: Icon(isRecording ? Icons.stop : Icons.mic, color: Colors.white, size: 40),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}