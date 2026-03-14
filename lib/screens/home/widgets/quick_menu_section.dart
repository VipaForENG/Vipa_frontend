import 'package:flutter/material.dart';
// [임포트] 클릭 시 이동할 실제 화면 파일들
import '../../conversation/conversation_screen.dart';
import '../../grammar/grammar_screen.dart'; // 우리가 만든 '오늘의 어휘' UI가 들어있는 파일

/// [클래스] QuickMenuSection
/// 목적: 메인 화면에서 '실전회화'와 '오늘의 어휘'로 빠르게 이동할 수 있는 가로 스크롤 메뉴바를 생성합니다.
class QuickMenuSection extends StatelessWidget {
  const QuickMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    // [1. 데이터 정의] 화면에 표시할 메뉴 리스트
    // 항목을 2개로 줄이고, '오늘의 어휘'가 우리가 만든 GrammarScreen을 바라보도록 설정했습니다.
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': '실전회화', 
        'icon': Icons.chat_bubble_outline, 
        'color': Colors.blueAccent, 
        'page': const ConversationScreen()
      },
      {
        'title': '오늘의 어휘', // 기존 '단어/문법'을 통합한 명칭
        'icon': Icons.auto_awesome, 
        'color': Colors.orangeAccent, 
        'page': const GrammarScreen() // 위에서 만든 0/10 퀴즈 화면으로 연결
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [위젯] 섹션 타이틀
        const Text('학습 바로가기',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        // [위젯] 가로 스크롤 리스트 영역
        SizedBox(
          height: 100, // 카드의 세로 높이 고정
          child: ListView.separated(
            scrollDirection: Axis.horizontal, // 가로 방향 스크롤 설정
            itemCount: menuItems.length,      // 메뉴 개수만큼 생성
            // 아이템 사이의 간격 설정 (12픽셀)
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = menuItems[index];
              
              // [로직] 카드 클릭 시 반응을 위한 InkWell 위젯
              return InkWell(
                onTap: () {
                  // 클릭 시 Navigator를 통해 해당 페이지(item['page'])로 이동
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => item['page']),
                  );
                },
                borderRadius: BorderRadius.circular(16), // 터치 효과(물결)의 범위 제한
                child: _buildMenuCard(item['title'], item['icon'], item['color']),
              );
            },
          ),
        ),
      ],
    );
  }

  /// [함수] _buildMenuCard
  /// 목적: 개별 메뉴 카드의 시각적인 디자인(아이콘, 글자, 배경)을 담당합니다.
  /// @param title: 메뉴 이름, icon: 아이콘 모양, color: 포인트 색상
  Widget _buildMenuCard(String title, IconData icon, Color color) {
    return Container(
      width: 120, // 카드의 가로 길이 (2개 항목에 맞춰 살짝 넓힘)
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16), // 둥근 테두리
        border: Border.all(color: Colors.grey.shade100), // 아주 연한 외곽선
        boxShadow: [
          // 하단에 살짝 깔리는 부드러운 그림자 효과
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 8, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
        children: [
          // [디자인] 아이콘 배경 (포인트 색상을 연하게 깐 원형)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1), // 배경색만 10% 농도로 설정
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 10),
          // [디자인] 메뉴 글자
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}