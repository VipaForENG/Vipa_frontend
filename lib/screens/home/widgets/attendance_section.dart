import 'package:flutter/material.dart';

class AttendanceSection extends StatelessWidget {
  const AttendanceSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> days = ['월', '화', '수', '목', '금', '토', '일'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('출석체크', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // 리스트 데이터를 받아 반복적으로 요일 위젯 생성
            children: days.map((day) => _buildDayCircle(day)).toList(),
          ),
        ],
      ),
    );
  }

  /// [함수] _buildDayCircle
  /// 목적: 요일별 출석체크용 원형 UI를 생성합니다.
  /// 인자: day(요일 텍스트)
  /// 반환: 요일 텍스트가 담긴 원형 Container 위젯
  Widget _buildDayCircle(String day) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Center(
        child: Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ),
    );
  }
}