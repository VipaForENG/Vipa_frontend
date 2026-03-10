import 'package:flutter/material.dart';
// [추가] tts 라이브러리 사용을 위해 추가 필요 (예: flutter_tts)
// import 'package:flutter_tts/flutter_tts.dart';

/// [클래스] ConversationScreen
/// 목적: 타이핑 퀴즈를 통한 영어 학습 및 정답 시 TTS 발화 기능 제공.
class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();

  // [변수] 학습 상태 관리
  String _targetSentence = "My boss was totally ______ today.";
  String _correctAnswer = "frustrated";
  bool _isAnswered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('실전 회화 퀴즈')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // [위젯] 문제 영역
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(16)),
              child: Text(_targetSentence, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),

            // [위젯] 정답 타이핑 입력창
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: "빈칸에 들어갈 단어를 입력하세요",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (value) => _checkAnswer(value), // [로직] 엔터키 입력 시 정답 체크
            ),

            const Spacer(),

            // [위젯] 상태 표시 (정답 시 다음 문제 버튼 활성화)
            if (_isAnswered)
              ElevatedButton(
                onPressed: _nextQuestion,
                child: const Text("다음 문제로"),
              ),
          ],
        ),
      ),
    );
  }

  /// [함수] _checkAnswer
  /// 목적: 입력된 정답을 검증하고, 맞으면 TTS로 읽어줍니다.
  void _checkAnswer(String input) {
    if (input.trim().toLowerCase() == _correctAnswer.toLowerCase()) {
      setState(() => _isAnswered = true);
      _speakSentence(_targetSentence.replaceAll("______", _correctAnswer));
    } else {
      // [로직] 틀렸을 경우 흔들림 애니메이션 등을 추가 가능
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("다시 생각해보세요!")));
    }
  }

  /// [함수] _speakSentence
  /// 목적: 정답 문장을 TTS로 재생합니다.
  Future<void> _speakSentence(String text) async {
    // [로직] 여기에 flutter_tts 인스턴스를 통한 발화 로직 구현
    print("TTS 재생: $text");
  }

  /// [함수] _nextQuestion
  /// 목적: 다음 문제를 가져오고 UI 상태를 초기화합니다.
  void _nextQuestion() {
    setState(() {
      _isAnswered = false;
      _textController.clear();
      // [로직] 서버에서 다음 문제를 요청하는 비동기 처리 예정
    });
  }
}