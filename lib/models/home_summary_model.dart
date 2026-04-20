class HomeSummary {
  final String nickname;
  final String tier;
  final double topPercent;
  final List<WeeklyData> weeklyData;
  final List<String> attendance; // [수정] bool -> String 리스트로 변경

  HomeSummary({
    required this.nickname,
    required this.tier,
    required this.topPercent,
    required this.weeklyData,
    required this.attendance,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    return HomeSummary(
      nickname: json['nickname'],
      tier: json['tier'],
      topPercent: (json['top_percent'] as num).toDouble(),
      weeklyData: (json['weekly_data'] as List)
          .map((i) => WeeklyData.fromJson(i))
          .toList(),
      // [수정] 백엔드에서 주는 "attendance" 키를 사용하고 String 리스트로 파싱
      attendance: List<String>.from(json['attendance'] ?? []),
    );
  }
}

class WeeklyData {
  final String date;
  final int convEnergy;
  final int vocabEnergy;
  final int totalEnergy;

  WeeklyData({
    required this.date,
    required this.convEnergy,
    required this.vocabEnergy,
    required this.totalEnergy,
  });

  factory WeeklyData.fromJson(Map<String, dynamic> json) {
    return WeeklyData(
      date: json['date'],
      convEnergy: json['conv_energy'],
      vocabEnergy: json['vocab_energy'],
      totalEnergy: json['total_energy'],
    );
  }
}