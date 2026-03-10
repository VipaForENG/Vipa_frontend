import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // [패키지] 복합 차트 구현을 위해 사용

/// [클래스] LearningChartSection
/// 목적: 스케치 이미지와 동일하게 막대 그래프 + 꺾은선 그래프 + 성취율 수치를 한 화면에 보여줍니다.
class LearningChartSection extends StatelessWidget {
  const LearningChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300), // 스케치의 박스 테두리 느낌 반영
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // [텍스트] 왼쪽 상단 타이틀: 학습정보
          const Text('학습정보',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          // [위젯] Row: 차트 영역과 오른쪽 성취율 정보를 가로로 배치
          Row(
            children: [
              // 1. 왼쪽 차트 영역 (막대 + 선 겹침)
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 120,
                  child: Stack(
                    children: [
                      // [위젯] BarChart: 배경에 깔리는 막대 그래프
                      BarChart(_barChartData()),
                      // [위젯] LineChart: 막대 위에 겹쳐지는 꺾은선 그래프
                      LineChart(_lineChartData()),
                    ],
                  ),
                ),
              ),

              // 2. 오른쪽 성취율 정보 영역 (스케치의 '90%' 부분)
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('학습 성취율',
                        style: TextStyle(fontSize: 10, color: Colors.grey)),
                    SizedBox(height: 4),
                    Text('90%',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// [함수] _barChartData
  /// 목적: 차트 배경에 들어갈 막대 그래프의 데이터와 디자인을 정의합니다.
  BarChartData _barChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 10,
      barTouchData: BarTouchData(enabled: false), // 터치 효과 끔
      titlesData: const FlTitlesData(show: false), // 축 이름 숨김 (스케치 참고)
      gridData: const FlGridData(show: false),    // 그리드 숨김
      borderData: FlBorderData(show: false),      // 테두리 숨김
      barGroups: [
        _makeBar(0, 7),
        _makeBar(1, 4),
        _makeBar(2, 9),
        _makeBar(3, 6),
      ],
    );
  }

  /// [함수] _lineChartData
  /// 목적: 막대 그래프 위에 올라갈 꺾은선 그래프의 데이터와 디자인을 정의합니다.
  LineChartData _lineChartData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: 10,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 5), // 막대 위치에 맞춘 점들
            FlSpot(1, 8),
            FlSpot(2, 4),
            FlSpot(3, 7),
          ],
          isCurved: false, // 스케치처럼 직선으로 연결
          color: Colors.orange, // 선 색상 (막대와 구분)
          barWidth: 2,
          dotData: const FlDotData(show: true), // 꺾이는 지점에 점 표시
        ),
      ],
    );
  }

  /// [함수] _makeBar
  /// 목적: 막대 그래프의 개별 막대 디자인을 생성합니다.
  BarChartGroupData _makeBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: Colors.blue.withOpacity(0.3), // 선이 잘 보이도록 막대는 반투명하게 설정
          width: 16,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}