import 'package:flutter/material.dart';
import '../../../design/circle_design.dart'; //

class AttendanceSection extends StatelessWidget {
  const AttendanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
    // 임시 데이터: 월, 화만 출석한 상태라고 가정
    final List<bool> attendanceStatus = [true, true, false, false, false, false, false];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min, // 카드 내부 여백 최적화
      children: [
        const Text(
          '출석체크', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2D3436))
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            return circleContainer(
              days[index], 
              isDone: attendanceStatus[index]
            );
          }),
        ),
      ],
    );
  }
}