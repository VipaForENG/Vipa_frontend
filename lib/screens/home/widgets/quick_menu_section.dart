import 'package:flutter/material.dart';
// 디자인 위젯들 임포트
import '../../../design/button_design.dart';
import '../../../design/section_header.dart'; // SectionHeader 사용을 위해 추가
// 화면 이동 대상 임포트
import '../../conversation/conversation_screen.dart';
import '../../grammar/grammar_screen.dart';

class QuickMenuSection extends StatelessWidget {
  const QuickMenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 하드코딩된 Text 대신, 미리 만들어둔 SectionHeader를 사용합니다.
        const SectionHeader(
          title: '학습 바로가기',
          icon: Icons.rocket_launch_rounded, // 섹션의 성격에 맞는 아이콘
          color: Color.fromARGB(255, 44, 50, 51), // 프로젝트 메인 컬러
        ),

        const SizedBox(height: 16), // 헤더와 버튼 사이 간격 최적화

        Row(
          children: [
            // [수정] 첫 번째 버튼을 Expanded로 감싸 남은 공간의 절반을 차지하게 함
            Expanded(
              child: vipaPrimaryButton(
                title: "실전회화",
                icon: Icons.chat_bubble_outline,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConversationScreen(),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12), // 버튼 사이 간격 유지 (절대값)

            // [수정] 두 번째 버튼도 Expanded로 감싸 남은 공간의 절반을 차지하게 함
            Expanded(
              child: vipaPrimaryButton(
                title: "오늘의 어휘",
                icon: Icons.auto_awesome,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GrammarScreen()),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}