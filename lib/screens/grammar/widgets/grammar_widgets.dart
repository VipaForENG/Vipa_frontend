import 'package:flutter/material.dart';

/// 상단 애니메이션 진행바
class GrammarProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const GrammarProgressBar({super.key, required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160, height: 24,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            width: 160 * (current / total),
            decoration: BoxDecoration(
              color: Colors.orangeAccent,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          Center(
            child: Text("$current/$total", 
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// 연핑크색 힌트 박스
class HintBox extends StatelessWidget {
  final String hint;
  const HintBox({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(hint, style: const TextStyle(color: Color(0xFFFF7088), fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}