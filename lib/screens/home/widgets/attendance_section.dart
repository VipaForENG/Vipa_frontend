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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('출석체크', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            // 🔥 연속 출석 배지 UI
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            bool isDone = attendanceList.contains(days[index]);
            return circleContainer(days[index], isDone: isDone);
          }),
        ),
        const SizedBox(height: 16),
        // 🔥 사용자를 위한 힌트 카드 추가
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blueGrey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blueGrey[400]),
              const SizedBox(width: 8),
              Text(
                '매일 한 번 이상 공부를 해야 자동 출석이 돼요!',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}