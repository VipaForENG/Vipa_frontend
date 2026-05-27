import 'package:flutter/foundation.dart';

// ==========================================
// [유틸리티 함수]
// ==========================================
Map<String, dynamic> asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> asList(dynamic value) {
  if (value is List) return value;
  return const [];
}

DateTime? parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

// ==========================================
// [모델 클래스]
// ==========================================
class RecentConversationSession {
  final int sessionId;
  final String scenarioTitle;
  final String category;
  final DateTime? createdAt;
  final String? audioUrl;

  RecentConversationSession({
    required this.sessionId,
    required this.scenarioTitle,
    required this.category,
    required this.createdAt,
    required this.audioUrl,
  });

  factory RecentConversationSession.fromJson(Map<String, dynamic> json) {
    return RecentConversationSession(
      sessionId: json['session_id'] ?? 0,
      scenarioTitle: json['scenario_title'] ?? '실전회화 세션',
      category: json['category'] ?? '미분류',
      createdAt: parseDate(json['created_at']),
      audioUrl: json['audio_url'],
    );
  }
}

// ✨ [신규 추가] 스크립트 상세 모델
class ScriptLineItem {
  final String role;
  final String originalText;
  final String? translatedText;
  final String? correctedText;
  final String? feedbackComment;
  final DateTime? createdAt;

  ScriptLineItem({
    required this.role,
    required this.originalText,
    this.translatedText,
    this.correctedText,
    this.feedbackComment,
    this.createdAt,
  });

  factory ScriptLineItem.fromJson(Map<String, dynamic> json) {
    return ScriptLineItem(
      role: json['role'] ?? 'user',
      originalText: json['original_text'] ?? '',
      translatedText: json['translated_text'],
      correctedText: json['corrected_text'],
      feedbackComment: json['feedback_comment'],
      createdAt: parseDate(json['created_at']),
    );
  }
}

class ConversationScriptDetail {
  final int sessionId;
  final String scenarioTitle;
  final String aiPassageEn; 
  final String aiPassageKo; 
  final List<dynamic> fullTurns; // ✨ 추가
  final List<ScriptLineItem> scripts;

  ConversationScriptDetail({
    required this.sessionId,
    required this.scenarioTitle,
    required this.aiPassageEn,
    required this.aiPassageKo,
    required this.fullTurns, // ✨ 추가
    required this.scripts,
  });

  factory ConversationScriptDetail.fromJson(Map<String, dynamic> json) {
    debugPrint('Parsing ConversationScriptDetail from JSON: $json'); // ✨ 디버그 출력 추가
    
    return ConversationScriptDetail(
      sessionId: json['session_id'] ?? 0,
      scenarioTitle: json['scenario_title'] ?? '실전 회화',
      aiPassageEn: json['ai_passage_en'] ?? '',
      aiPassageKo: json['ai_passage_ko'] ?? '',
      fullTurns: json['full_turns'] ?? [], // ✨ 파싱 추가
      scripts: asList(json['scripts'])
          .map((item) => ScriptLineItem.fromJson(asMap(item))).toList(),
    );
  }
}

// (어휘 관련 기존 모델들은 그대로 유지)
class DailyVocabularyStats {
  final int totalQuizzesToday;
  final int correctQuizzesToday;
  final double accuracyRate;

  DailyVocabularyStats({
    required this.totalQuizzesToday,
    required this.correctQuizzesToday,
    required this.accuracyRate,
  });

  factory DailyVocabularyStats.fromJson(Map<String, dynamic> json) {
    return DailyVocabularyStats(
      totalQuizzesToday: json['total_quizzes_today'] ?? 0,
      correctQuizzesToday: json['correct_quizzes_today'] ?? 0,
      accuracyRate: (json['accuracy_rate'] ?? 0).toDouble(),
    );
  }
}

class WrongVocabularyItem {
  final int vocabId;
  final String targetWord;
  final String expression;
  final String meaning;
  final int incorrectCount;

  WrongVocabularyItem({
    required this.vocabId,
    required this.targetWord,
    required this.expression,
    required this.meaning,
    required this.incorrectCount,
  });

  factory WrongVocabularyItem.fromJson(Map<String, dynamic> json) {
    return WrongVocabularyItem(
      vocabId: json['vocab_id'] ?? 0,
      targetWord: json['target_word'] ?? '',
      expression: json['expression'] ?? '',
      meaning: json['meaning'] ?? '',
      incorrectCount: json['incorrect_count'] ?? 0,
    );
  }
}

class BookmarkedSentenceItem {
  final int vocabId;
  final String targetWord;
  final String expression;
  final String meaning;

  BookmarkedSentenceItem({
    required this.vocabId,
    required this.targetWord,
    required this.expression,
    required this.meaning,
  });

  factory BookmarkedSentenceItem.fromJson(Map<String, dynamic> json) {
    return BookmarkedSentenceItem(
      vocabId: json['vocab_id'] ?? 0,
      targetWord: json['target_word'] ?? '',
      expression: json['expression'] ?? '',
      meaning: json['meaning'] ?? '',
    );
  }
}