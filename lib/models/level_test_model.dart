// lib/models/level_test_model.dart

class LevelTestResult {
  final String cefrLevel;
  final double overallScore;
  final List<String> weaknessTags;
  final int grammarScore;
  final int vocabularyScore;
  final String detailedFeedback;
  final int correctAnswersCount;

  LevelTestResult({
    required this.cefrLevel,
    required this.overallScore,
    required this.weaknessTags,
    required this.grammarScore,
    required this.vocabularyScore,
    required this.detailedFeedback,
    required this.correctAnswersCount,
  });

  // lib/models/level_test_model.dart

factory LevelTestResult.fromJson(Map<String, dynamic> json) {
    final raw = json['raw_analysis_json'] ?? {};
    
    // 💡 문자열로 온 태그를 콤마 기준으로 쪼개서 리스트로 만듭니다.
    String tagsString = json['weakness_tags'] ?? "";
    List<String> tagsList = tagsString.isNotEmpty 
        ? tagsString.split(',').map((e) => e.trim()).toList() 
        : [];

    return LevelTestResult(
      cefrLevel: json['cefr_level'] ?? "B1",
      overallScore: (json['overall_score'] ?? 0).toDouble(),
      weaknessTags: tagsList, // 쪼개진 리스트 삽입
      grammarScore: raw['grammar_score'] ?? 0,
      vocabularyScore: raw['vocabulary_score'] ?? 0,
      detailedFeedback: raw['detailed_feedback'] ?? "",
      correctAnswersCount: raw['correct_answers_count'] ?? 0,
    );
  }
}