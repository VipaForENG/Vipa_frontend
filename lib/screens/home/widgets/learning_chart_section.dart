import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/home_summary_model.dart';

class LearningChartSection extends StatelessWidget {
  final List<WeeklyData> weeklyData;

  const LearningChartSection({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    // 데이터 중 최대값 계산
    double maxEnergy = weeklyData.map((e) => e.totalEnergy.toDouble()).fold(20.0, (a, b) => a > b ? a : b);
    double dynamicMaxY = maxEnergy * 1.2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('학습정보', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 150,
                  child: Stack(
                    children: [
                      BarChart(_barChartData(dynamicMaxY)),
                      LineChart(_lineChartData(dynamicMaxY)),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              _buildTotalEnergySummary(),
            ],
          ),
        ],
      ),
    );
  }

  BarChartData _barChartData(double maxY) {
    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barTouchData: BarTouchData(enabled: false),
      titlesData: const FlTitlesData(show: false),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: weeklyData.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.totalEnergy.toDouble(),
              width: 16,
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xFFE0EAFC), Color(0xFFB3CDE0)],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  LineChartData _lineChartData(double maxY) {
    return LineChartData(
      lineTouchData: const LineTouchData(enabled: false),
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: 6, // [수정] 데이터 인덱스가 0~6이므로 maxX를 6으로 고정하여 꺾임 방지
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          // [수정] 0.5를 더하지 않고 인덱스 그대로 사용 (가운데 정렬이 필요하면 BarChart와 동일하게)
          spots: weeklyData.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.totalEnergy.toDouble())).toList(),
          isCurved: true,
          color: Colors.blueAccent,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [Colors.blueAccent.withValues(alpha: 0.2), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalEnergySummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text('총 학습 에너지', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
        Text(
          '${weeklyData.isNotEmpty ? weeklyData.last.totalEnergy : 0}',
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent, letterSpacing: -1),
        ),
      ],
    );
  }
}