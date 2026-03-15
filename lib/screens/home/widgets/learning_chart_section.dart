import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LearningChartSection extends StatelessWidget {
  const LearningChartSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Card_Container 내부 여백만 줍니다. 테두리와 배경색은 지웠습니다.
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습정보',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold, 
              color: Color(0xFF2D3436)
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // 1. 차트 영역: 조금 더 넓고 시원하게 배치
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 140, // 높이를 살짝 키웠습니다.
                  child: Stack(
                    children: [
                      BarChart(_barChartData()),
                      LineChart(_lineChartData()),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 2. 성취율 영역: 가독성 강조
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '학습 성취율',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '90%',
                    style: TextStyle(
                      fontSize: 32, // 숫자를 더 크게!
                      fontWeight: FontWeight.bold, 
                      color: Colors.blueAccent,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  BarChartData _barChartData() {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 10,
      barTouchData: BarTouchData(enabled: false),
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: [
        _makeBar(0, 7),
        _makeBar(1, 4),
        _makeBar(2, 9),
        _makeBar(3, 6),
      ],
    );
  }

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
          FlSpot(0.5, 5),
          FlSpot(1.5, 8),
          FlSpot(2.5, 4),
          FlSpot(3.5, 7),
        ],
        isCurved: true, // 곡선 활성화
        // curveSize 대신 아래의 속성들을 사용하여 부드러움을 조절합니다.
        preventCurveOverShooting: true, 
        color: Colors.orangeAccent, 
        barWidth: 3, 
        isStrokeCapRound: true,
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 4,
            color: Colors.white,
            strokeWidth: 2,
            strokeColor: Colors.orangeAccent,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: Colors.orangeAccent.withValues(alpha: 0.1), 
        ),
      ),
    ],
  );
}

  BarChartGroupData _makeBar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFFF1F2F6), // 막대 색상을 연한 회색으로 변경 (선이 돋보이게)
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}