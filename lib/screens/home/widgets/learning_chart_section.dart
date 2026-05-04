import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../models/home_summary_model.dart';

class LearningChartSection extends StatelessWidget {
  final List<WeeklyData> weeklyData;

  const LearningChartSection({super.key, required this.weeklyData});

  @override
  Widget build(BuildContext context) {
    // 데이터 중 최대값 계산 (최소 20으로 설정하여 0일 때도 차트 높이 유지)
    double maxEnergy = weeklyData
        .map((e) => e.totalEnergy.toDouble())
        .fold(20.0, (a, b) => a > b ? a : b);
    double dynamicMaxY = maxEnergy * 1.3; // 상단 여유 공간

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '학습정보',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: 180, // 라벨 공간을 위해 높이 살짝 상향
                  child: Stack(
                    children: [
                      BarChart(_barChartData(dynamicMaxY)),
                      // 라인 차트는 바 차트의 중앙에 위치하도록 정렬 패딩 확인 필요
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 22,
                        ), // 하단 타이틀 높이만큼 띄움
                        child: LineChart(_lineChartData(dynamicMaxY)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 15),
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
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int index = value.toInt();
              if (index < 0 || index >= weeklyData.length)
                return const SizedBox();
              // "2026-04-27" -> "27" 또는 요일로 변환
              String dateStr = weeklyData[index].date.split('-').last;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  dateStr,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      ),
      barGroups: weeklyData.asMap().entries.map((entry) {
        return BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.totalEnergy.toDouble(),
              width: 14,
              borderRadius: BorderRadius.circular(4),
              //  배경 막대 추가: 데이터가 0일 때도 슬롯이 보이게 함
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY * 0.8,
                color: const Color.fromARGB(255, 200, 200, 200),
              ),
              gradient: const LinearGradient(
                colors: [Color(0xFFE0EAFC), Color(0xFF4A90E2)],
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
      minX: -0.2, // 바 차트와 중앙 정렬을 맞추기 위한 미세 조정
      maxX: 6.2,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: weeklyData
              .asMap()
              .entries
              .map(
                (e) => FlSpot(e.key.toDouble(), e.value.totalEnergy.toDouble()),
              )
              .toList(),
          isCurved: true,
          color: const Color.fromARGB(255, 74, 144, 226).withValues(alpha: 0.8),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: true),
          belowBarData: BarAreaData(show: false),
        ),
      ],
    );
  }

  Widget _buildTotalEnergySummary() {
    // 1. 휴대폰의 오늘 날짜(YYYY-MM-DD)를 가져옵니다.
    String todayStr = DateTime.now().toIso8601String().split('T').first;
    
    // 2. 백엔드에서 받은 데이터 중 '진짜 오늘 날짜'와 일치하는 것을 찾습니다.
    int todayEnergy = 0;
    try {
      todayEnergy = weeklyData.firstWhere((e) => e.date == todayStr).totalEnergy;
    } catch (e) {
      todayEnergy = 0; // 안전 장치
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Text(
          '오늘 획득 에너지',
          style: TextStyle(
            fontSize: 11,
            color: Colors.blueGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '$todayEnergy',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: todayEnergy > 0 ? const Color.fromARGB(255, 74, 144, 226) : const Color.fromARGB(255, 192, 192, 192),
            letterSpacing: -1,
          ),
        ),
        if (todayEnergy == 0)
          const Text(
            '학습이 필요해요! 🏃',
            style: TextStyle(
              fontSize: 10,
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
