import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'conversation_provider.dart';
import 'widgets/conversation_widgets.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConversationProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: ConversationTopBar(value: provider.progress),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.35,
                  left: 20, right: 40,
                  child: AiSpeechBubble(en: provider.aiEnglish, ko: provider.aiKorean),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: _buildBottomCard(provider),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(color: Colors.grey[300], child: const Center(child: Text("배경 준비 중")));
  }

  Widget _buildBottomCard(ConversationProvider provider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: provider.isAnswered 
          ? _buildResultView(provider) 
          : _buildInputView(provider),
      ),
    );
  }

  List<Widget> _buildInputView(ConversationProvider provider) {
    return [
      Text(provider.userTargetSentence, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 30),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _miniIconButton(Icons.help_outline, "힌트"),
          _micButton(() => provider.setAnswered(true)),
          _miniIconButton(Icons.keyboard_alt_outlined, "키보드"),
        ],
      ),
    ];
  }

  List<Widget> _buildResultView(ConversationProvider provider) {
    return [
      const Text("Perfect!!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF8877FF))),
      const SizedBox(height: 15),
      Row(
        children: [
          Expanded(child: ActionButton(icon: Icons.refresh, label: "재도전", onTap: () => provider.setAnswered(false))),
          const SizedBox(width: 8),
          Expanded(child: ActionButton(icon: Icons.play_arrow, label: "다음 문제", isPrimary: true, onTap: () => provider.nextStep())),
        ],
      )
    ];
  }

  // 작은 헬퍼 위젯들...
  Widget _micButton(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: const BoxDecoration(color: Color(0xFF8877FF), shape: BoxShape.circle),
        child: const Icon(Icons.mic, color: Colors.white, size: 38),
      ),
    );
  }

  Widget _miniIconButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8877FF).withValues(alpha: 0.6), size: 28),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8877FF))),
      ],
    );
  }
}