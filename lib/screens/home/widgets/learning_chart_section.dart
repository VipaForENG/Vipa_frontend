import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/home_summary_model.dart'; // 모델 임포트

class LearningChartSection extends StatelessWidget {
  final List<WeeklyData> weeklyData;

  const LearningChartSection({
    super.key, 
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    // 7일치 데이터를 역순 혹은 순서대로 사용 (weeklyData가 7일치라고 가정)
    return Padding(
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
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 140,
                  child: Stack(
                    children: [
                      BarChart(_barChartData()),
                      LineChart(_lineChartData()),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    '총 학습 에너지',
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weeklyData.isNotEmpty ? weeklyData.last.totalEnergy : 0}', // 최신 데이터 표시
                    style: const TextStyle(
                      fontSize: 32,
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
      maxY: 20, // 필요 시 최대값 동적 조절
      barTouchData: BarTouchData(enabled: false),
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: weeklyData.asMap().entries.map((entry) {
        return _makeBar(entry.key, entry.value.totalEnergy.toDouble());
      }).toList(),
    );
  }

  LineChartData _lineChartData() {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minY: 0,
      maxY: 20,
      lineBarsData: [
        LineChartBarData(
          spots: weeklyData.asMap().entries.map((entry) {
            return FlSpot(entry.key.toDouble() + 0.5, entry.value.totalEnergy.toDouble());
          }).toList(),
          isCurved: true,
          preventCurveOverShooting: true, 
          color: Colors.orangeAccent, 
          barWidth: 3, 
          isStrokeCapRound: true,
          dotData: FlDotData(show: true),
          belowBarData: BarAreaData(show: true, color: Colors.orangeAccent.withValues(alpha: 0.1)),
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
          color: const Color(0xFFF1F2F6),
          width: 18,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}