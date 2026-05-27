import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../api/api_service.dart';
import '../../models/learning_history_models.dart'; // ✨ 분리한 모델과 유틸리티 함수 임포트

class LearningHistoryProvider extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  List<RecentConversationSession> recentSessions = [];
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
    final response = await ApiService.dio.get('/conversation/dashboard/history');
    final data = asMap(response.data); // ✨ 이제 public 함수로 호출

    recentSessions = asList(data['recent_sessions']) 
        .map((item) => RecentConversationSession.fromJson(asMap(item))).toList();
  }

  Future<ConversationScriptDetail?> fetchSessionScript(int sessionId) async {
    try {
      final response = await ApiService.dio.get('/conversation/dashboard/history/$sessionId');
      return ConversationScriptDetail.fromJson(asMap(response.data));
    } catch (e) {
      debugPrint('스크립트 상세 로드 에러: $e');
      return null;
    }
  }

  Future<void> _loadVocabularyHistory() async {
    final response = await ApiService.dio.get('/vocabulary/history/today');
    final data = asMap(response.data);

    dailyStats = DailyVocabularyStats.fromJson(asMap(data['daily_stats']));
    wrongWords = asList(data['wrong_vocab_list'])
        .map((item) => WrongVocabularyItem.fromJson(asMap(item))).toList();
  }

  Future<void> _loadBookmarkedSentences() async {
    final response = await ApiService.dio.get('/vocabulary/bookmarks');
    final data = asMap(response.data);

    bookmarkedSentences = asList(data['items'])
        .map((item) => BookmarkedSentenceItem.fromJson(asMap(item))).toList();
  }
}