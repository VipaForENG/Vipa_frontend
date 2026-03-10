import 'package:flutter/material.dart';

/// [클래스] GrammarScreen
/// 목적: 문법 개념을 설명하고 간단한 문법 퀴즈를 제공하는 학습 페이지.
class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  // [변수] 더미 데이터: 문법 개념과 연습 문제
  final Map<String, String> _grammarTopic = {
    'title': '현재 완료형 (Present Perfect)',
    'explanation': '과거의 사건이 현재까지 영향을 미칠 때 사용합니다. (have/has + p.p.)',
    'quiz': 'I (  ) to Paris twice. (have been / was)',
  };

  final TextEditingController _answerController = TextEditingController();
  String _feedback = "";

  /// [함수] _checkGrammar
  /// 목적: 입력된 문법 퀴즈의 정답을 판별합니다.
  void _checkGrammar() {
    setState(() {
      if (_answerController.text.toLowerCase().contains("have been")) {
        _feedback = "정답입니다! 현재 완료의 경험적 용법을 잘 이해하고 계시네요.";
      } else {
        _feedback = "다시 한번 생각해 보세요. 주어가 I일 때는 have를 씁니다.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('문법 학습')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [위젯] 문법 개념 설명 카드
            _buildExplanationCard(),
            const SizedBox(height: 30),

            // [위젯] 문법 퀴즈 영역
            Text("연습 문제", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(_grammarTopic['quiz']!, style: const TextStyle(fontSize: 16)),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(hintText: "정답을 입력하세요"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _checkGrammar, child: const Text("정답 확인")),
            const SizedBox(height: 10),
            Text(_feedback, style: TextStyle(color: _feedback.contains("정답") ? Colors.green : Colors.red)),
          ],
        ),
      ),
    );
  }

  /// [함수] _buildExplanationCard
  /// 목적: 문법 개념을 가독성 있게 보여주는 카드 UI 생성.
  Widget _buildExplanationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_grammarTopic['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 10),
          Text(_grammarTopic['explanation']!, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}