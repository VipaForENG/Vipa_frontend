import 'package:flutter/material.dart';
// [임포트] 아까 만든 기초 페이지들 연결
import '../../conversation/conversation_screen.dart';
import '../../vocabulary/vocabulary_screen.dart';
import '../../grammar/grammar_screen.dart';

/// [클래스] QuickMenuSection
/// 목적: 실전회화, 단어, 문법 메뉴 카드를 나열하고 클릭 시 해당 페이지로 이동합니다.
class QuickMenuSection extends StatelessWidget {
  const QuickMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    // [데이터] 각 메뉴의 메타데이터(타이틀, 아이콘, 색상, 이동할 페이지)를 정의
    final List<Map<String, dynamic>> menuItems = [
      {'title': '실전회화', 'icon': Icons.chat_bubble_outline, 'color': Colors.blueAccent, 'page': const ConversationScreen()},
      {'title': '단어', 'icon': Icons.menu_book, 'color': Colors.greenAccent, 'page': const VocabularyScreen()},
      {'title': '문법', 'icon': Icons.psychology, 'color': Colors.orangeAccent, 'page': const GrammarScreen()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('학습 바로가기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: menuItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              // [로직] 카드 클릭 시 Navigator.push를 사용하여 해당 페이지로 화면 전환
              return InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => item['page']),
                ),
                child: _buildMenuCard(item['title'], item['icon'], item['color']),
              );
            },
          ),
        ),
      ],
    );
  }

  /// [함수] _buildMenuCard
  /// 목적: 개별 메뉴 카드의 외형(테두리, 그림자 등)을 구성합니다.
  Widget _buildMenuCard(String title, IconData icon, Color color) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}