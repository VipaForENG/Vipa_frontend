import 'package:flutter/material.dart';
import '../../../design/button_design.dart'; 
import '../../conversation/conversation_screen.dart';
import '../../grammar/grammar_screen.dart';

class QuickMenuSection extends StatelessWidget {
  const QuickMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '학습 바로가기',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // buttonDesign은 내부에 Expanded가 포함되어 있어 Row 안에서 바로 쓰면 됩니다.
            buttonDesign(
              "실전회화", 
              Icons.chat_bubble_outline, 
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ConversationScreen()))
            ),
            const SizedBox(width: 12), // 버튼 사이 간격
            buttonDesign(
              "오늘의 어휘", 
              Icons.auto_awesome, 
              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GrammarScreen()))
            ),
          ],
        ),
      ],
    );
  }
}