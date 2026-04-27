class HomeSummary {
  final String nickname;
  final String tier;
  final double topPercent;
  final List<WeeklyData> weeklyData;
  final List<String> attendance;
  final int continuousAttendanceCount;
  final int studyAchievementRate; // 목표 대비 달성률

  HomeSummary({
    required this.nickname,
    required this.tier,
    required this.topPercent,
    required this.weeklyData,
    required this.attendance,
    required this.continuousAttendanceCount,
    required this.studyAchievementRate,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    return HomeSummary(
      nickname: json['nickname'] ?? "사용자",
      tier: json['tier'] ?? "BRONZE",
      topPercent: (json['top_percent'] ?? 0).toDouble(),
      weeklyData: (json['weekly_data'] as List?)
              ?.map((i) => WeeklyData.fromJson(i))
              .toList() ?? [],
      attendance: List<String>.from(json['attendance'] ?? []),
      continuousAttendanceCount: json['continuous_attendance_count'] ?? 0, // 🔥 매핑
      studyAchievementRate: json['study_achievement_rate'] ?? 0,
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
      date: json['date'] ?? "",
      // 4. [중요] 각 에너지가 null일 때 0으로 치환하여 int 타입 보장
      convEnergy: (json['conv_energy'] ?? 0) as int,
      vocabEnergy: (json['vocab_energy'] ?? 0) as int,
      totalEnergy: (json['total_energy'] ?? 0) as int,
    );
  }
}