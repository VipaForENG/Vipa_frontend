import 'package:flutter/material.dart';

/// 상단 트로피 진행바
class ConversationTopBar extends StatelessWidget {
  final double value;
  const ConversationTopBar({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.emoji_events, color: Colors.purpleAccent, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFCC99FF)),
            ),
          ),
        ),
      ],
    );
  }
}

/// AI 말풍선
class AiSpeechBubble extends StatelessWidget {
  final String en;
  final String ko;
  const AiSpeechBubble({super.key, required this.en, required this.ko});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(en, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(ko, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.volume_up, color: Colors.grey),
        ],
      ),
    );
  }
}

/// 하단 버튼 스타일 (모범답안, 재도전 등)
class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onTap;

  const ActionButton({
    super.key, 
    required this.icon, 
    required this.label, 
    this.isPrimary = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPrimary ? const Color(0xFF8877FF) : Colors.white;
    final contentColor = isPrimary ? Colors.white : const Color(0xFF8877FF);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: const Color(0xFF8877FF), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: contentColor, size: 20),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: contentColor, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}