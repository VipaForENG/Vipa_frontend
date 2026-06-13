class HomeSummary {
  final String nickname;
  final String tier;
  final double topPercent;
  final int totalLearningCount;
  final int todayVocabularyCount;
  final int todayConversationCount;
  final List<WeeklyData> weeklyData;
  final List<String> attendance;
  final List<String> attendanceDates;
  final int continuousAttendanceCount;
  final int studyAchievementRate; // 목표 대비 달성률

  HomeSummary({
    required this.nickname,
    required this.tier,
    required this.topPercent,
    required this.totalLearningCount,
    required this.todayVocabularyCount,
    required this.todayConversationCount,
    required this.weeklyData,
    required this.attendance,
    required this.attendanceDates,
    required this.continuousAttendanceCount,
    required this.studyAchievementRate,
  });

  factory HomeSummary.fromJson(Map<String, dynamic> json) {
    return HomeSummary(
      nickname: json['nickname'] ?? "사용자",
      tier: json['tier'] ?? "BRONZE",
      topPercent: _toDouble(json['top_percent'] ?? json['topPercent']),
      totalLearningCount: _toInt(
        json['total_learning_count'] ?? json['totalLearningCount'],
      ),
      todayVocabularyCount: _toInt(
        json['today_vocabulary_count'] ?? json['todayVocabularyCount'],
      ),
      todayConversationCount: _toInt(
        json['today_conversation_count'] ?? json['todayConversationCount'],
      ),
      weeklyData:
          ((json['weekly_data'] ?? json['weeklyData']) as List?)
              ?.map((i) => WeeklyData.fromJson(i))
              .toList() ??
          [],
      attendance: List<String>.from(json['attendance'] ?? []),
      attendanceDates: List<String>.from(
        json['attendance_dates'] ?? json['attendanceDates'] ?? [],
      ),
      continuousAttendanceCount: _toInt(
        json['continuous_attendance_count'] ??
            json['continuousAttendanceCount'],
      ),
      studyAchievementRate: _toInt(
        json['study_achievement_rate'] ?? json['studyAchievementRate'],
      ),
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
      convEnergy: _toInt(json['conv_energy'] ?? json['convEnergy']),
      vocabEnergy: _toInt(json['vocab_energy'] ?? json['vocabEnergy']),
      totalEnergy: _toInt(json['total_energy'] ?? json['totalEnergy']),
    );
  }
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0.0;
}
