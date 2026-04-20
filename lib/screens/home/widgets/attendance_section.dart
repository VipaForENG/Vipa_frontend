import 'package:flutter/material.dart';
import '../../../design/circle_design.dart';

class AttendanceSection extends StatelessWidget {
  final List<String> attendanceList;

  const AttendanceSection({
    super.key,
    required this.attendanceList,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint("🔍 [출석 데이터 확인]: $attendanceList");
    final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '출석체크',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(days.length, (index) {
            // 서버에서 받은 리스트에 해당 요일이 포함되어 있는지 확인
            bool isDone = attendanceList.contains(days[index]);
            
            return circleContainer(
              days[index],
              isDone: isDone,
            );
          }),
        ),
      ],
    );
  }
}