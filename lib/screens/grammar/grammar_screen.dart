import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 패키지 필요
import 'grammar_provider.dart';
import 'widgets/grammar_widgets.dart';

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Provider로부터 데이터와 상태를 가져옵니다.
    final provider = Provider.of<GrammarProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFD6EBFF),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GrammarProgressBar(current: provider.currentCount, total: provider.totalCount),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(35)),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(provider.quizData['category']!, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    Text(provider.quizData['korean']!, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 25),
                    HintBox(hint: provider.quizData['hint']!),
                    const SizedBox(height: 50),
                    _buildInputArea(provider),
                  ],
                ),
              ),
            ),
          ),
          _buildConfirmButton(provider),
        ],
      ),
    );
  }

  Widget _buildInputArea(GrammarProvider provider) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(provider.quizData['engBefore']!, style: const TextStyle(fontSize: 20)),
        _buildTextField(provider),
        Text(provider.quizData['engAfter']!, style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  Widget _buildTextField(GrammarProvider provider) {
    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: _answerController,
        onSubmitted: (_) => _handleCheck(provider),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20, 
          color: provider.isWrong ? Colors.red : Colors.blueAccent,
          fontWeight: FontWeight.bold
        ),
        decoration: InputDecoration(
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: provider.isWrong ? Colors.red : Colors.blueAccent)),
        ),
      ),
    );
  }

  void _handleCheck(GrammarProvider provider) {
    provider.checkAnswer(_answerController.text, () {
      _answerController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("정답입니다!")));
    });
  }

  Widget _buildConfirmButton(GrammarProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: () => _handleCheck(provider),
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B61FF)),
        child: const Text("확인", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}