import 'package:flutter/material.dart';
import '../../../design/circle_design.dart';

class AttendanceSection extends StatelessWidget {
  final List<String> attendanceList;
  final int streakCount;

  const AttendanceSection({
    super.key,
    required this.attendanceList,
    required this.streakCount,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
    final int currentDayIndex = DateTime.now().weekday - 1;

    // 🔥 [수정] 전체 섹션에 가로/세로 내부 여백을 추가하여 카드 테두리와 간격을 둡니다.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('출석체크', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436))
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🔥 $streakCount일 연속',
                  style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20), // 요일 원형들과의 간격 확대
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              bool isDone = attendanceList.contains(days[index]);
              bool isFuture = index > currentDayIndex;
              Widget circle = circleContainer(days[index], isDone: isDone);

              if (isFuture) {
                circle = Opacity(opacity: 0.3, child: circle);
              }

              return Expanded(
                child: Center(child: circle),
              );
            }),
          ),
          const SizedBox(height: 20),
          // 🔥 [수정] 하단 힌트 카드의 배경색을 조금 더 투명하게 조정하여 유리 질감 카드와 어울리게 함
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3), // 배경 파도와 어울리도록 투명도 조절
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.blueGrey[600]),
                const SizedBox(width: 8),
                Expanded( // 텍스트가 길어질 경우를 대비해 Expanded 추가
                  child: Text(
                    '매일 한 번 이상 공부를 해야 자동 출석이 돼요!',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey[800], fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}