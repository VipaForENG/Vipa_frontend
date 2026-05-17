import 'package:flutter/material.dart';
import '../../api/api_service.dart'; // ApiService 경로에 맞게 수정해주세요

class VocabularyDashboardProvider extends ChangeNotifier {
  bool isLoading = true;

  // 백엔드에서 받아온 최대 개수
  int maxNew = 0;
  int maxReview = 0;
  int maxRetry = 0;

  // 유저가 조절할 개수
  int chosenNew = 0;
  int chosenReview = 0;
  int chosenRetry = 0;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();

    try {
      // API에서 대시보드 데이터 호출
      final response = await ApiService.dio.get('/vocabulary/dashboard');
      if (response.statusCode == 200) {
        final data = response.data;
        maxNew = data['new_words_count'] ?? 0;
        maxReview = data['review_words_count'] ?? 0;
        maxRetry = data['retry_words_count'] ?? 0;

        // 초기값은 최대치로 꽉 채워둠
        chosenNew = maxNew;
        chosenReview = maxReview;
        chosenRetry = maxRetry;
      }
    } catch (e) {
      debugPrint("대시보드 로드 에러: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void adjustCount(String type, int delta) {
    if (type == 'new') {
      chosenNew = (chosenNew + delta).clamp(0, maxNew);
    } else if (type == 'review') {
      chosenReview = (chosenReview + delta).clamp(0, maxReview);
    } else if (type == 'retry') {
      chosenRetry = (chosenRetry + delta).clamp(0, maxRetry);
    }
    notifyListeners();
  }
}