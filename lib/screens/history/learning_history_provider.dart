import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../api/api_service.dart';

class LearningHistoryProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<RecentConversationSession> recentSessions = [];
  List<AiCorrectionSentence> aiCorrections = [];
  List<CategoryLearningProgress> categoryProgress = [];
  DailyVocabularyStats? dailyStats;
  List<WrongVocabularyItem> wrongWords = [];
  List<BookmarkedSentenceItem> bookmarkedSentences = [];

  Future<void> loadHistory() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final results = await Future.wait([
      _safeLoad(_loadConversationHistory),
      _safeLoad(_loadVocabularyHistory),
      _safeLoad(_loadBookmarkedSentences),
    ]);

    if (!results.contains(true)) {
      errorMessage = '학습내역을 불러오지 못했습니다.';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> _safeLoad(Future<void> Function() loader) async {
    try {
      await loader();
      return true;
    } on DioException catch (e) {
      debugPrint('Learning history API error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Learning history error: $e');
      return false;
    }
  }

  Future<void> _loadConversationHistory() async {
    final response = await ApiService.dio.get(
      '/conversation/dashboard/history',
    );
    final data = _asMap(response.data);

    recentSessions = _asList(
      data['recent_sessions'],
    ).map((item) => RecentConversationSession.fromJson(_asMap(item))).toList();
    aiCorrections = _asList(
      data['ai_corrections'],
    ).map((item) => AiCorrectionSentence.fromJson(_asMap(item))).toList();
    categoryProgress = _asList(
      data['category_progress'],
    ).map((item) => CategoryLearningProgress.fromJson(_asMap(item))).toList();
  }

  Future<void> _loadVocabularyHistory() async {
    final response = await ApiService.dio.get('/vocabulary/history/today');
    final data = _asMap(response.data);

    dailyStats = DailyVocabularyStats.fromJson(_asMap(data['daily_stats']));
    wrongWords = _asList(
      data['wrong_vocab_list'],
    ).map((item) => WrongVocabularyItem.fromJson(_asMap(item))).toList();
  }

  Future<void> _loadBookmarkedSentences() async {
    final response = await ApiService.dio.get('/vocabulary/bookmarks');
    final data = _asMap(response.data);

    bookmarkedSentences = _asList(
      data['items'],
    ).map((item) => BookmarkedSentenceItem.fromJson(_asMap(item))).toList();
  }
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const [];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

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
      createdAt: _parseDate(json['created_at']),
      audioUrl: json['audio_url'],
    );
  }
}

class AiCorrectionSentence {
  final int turnId;
  final int sessionId;
  final String userInput;
  final String correctedEnglish;
  final String feedbackKorean;
  final DateTime? createdAt;

  AiCorrectionSentence({
    required this.turnId,
    required this.sessionId,
    required this.userInput,
    required this.correctedEnglish,
    required this.feedbackKorean,
    required this.createdAt,
  });

  factory AiCorrectionSentence.fromJson(Map<String, dynamic> json) {
    return AiCorrectionSentence(
      turnId: json['turn_id'] ?? 0,
      sessionId: json['session_id'] ?? 0,
      userInput: json['user_input'] ?? '',
      correctedEnglish: json['corrected_en'] ?? '',
      feedbackKorean: json['feedback_ko'] ?? '',
      createdAt: _parseDate(json['created_at']),
    );
  }
}

class CategoryLearningProgress {
  final String category;
  final int completedSessions;

  CategoryLearningProgress({
    required this.category,
    required this.completedSessions,
  });

  factory CategoryLearningProgress.fromJson(Map<String, dynamic> json) {
    return CategoryLearningProgress(
      category: json['category'] ?? '미분류',
      completedSessions: json['completed_sessions'] ?? 0,
    );
  }
}

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
