import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_service.dart';
import '../models/vocabulary_dashboard_model.dart';

class VocabularyController extends GetxController {
  // ==========================================
  // [대시보드 영역 상태 관리 변수]
  // ==========================================
  var isLoadingDashboard = true.obs;
  VocabularyDashboardModel? dashboardData;
  var chosenNew = 0.obs;
  var chosenReview = 0.obs;
  var chosenRetry = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      isLoadingDashboard(true);
      final response = await ApiService.dio.get('/vocabulary/dashboard');
      if (response.statusCode == 200) {
        dashboardData = VocabularyDashboardModel.fromJson(response.data);
        chosenNew.value = dashboardData!.newWordsCount;
        chosenReview.value = dashboardData!.reviewWordsCount;
        chosenRetry.value = dashboardData!.retryWordsCount;
      }
    } on DioException catch (e) {
      debugPrint("🚨 대시보드 API 에러: ${e.message}");
    } finally {
      isLoadingDashboard(false);
    }
  }

  void adjustCount(String type, int delta) {
      if (dashboardData == null) {
        return;
      }
      
      if (type == 'new') {
        chosenNew.value = (chosenNew.value + delta).clamp(0, dashboardData!.newWordsCount);
      } else if (type == 'review') {
        chosenReview.value = (chosenReview.value + delta).clamp(0, dashboardData!.reviewWordsCount);
      } else if (type == 'retry') {
        chosenRetry.value = (chosenRetry.value + delta).clamp(0, dashboardData!.retryWordsCount);
      }
    }

  // ==========================================
  // 🔥 [이관 기능] 어휘 도메인 통합 API 통신 메서드
  // ==========================================

  // 1) 맞춤형 퀴즈 리스트 가져오기 API
  Future<List<dynamic>> getQuizList(int newC, int reviewC, int retryC) async {
    final response = await ApiService.dio.get(
      '/vocabulary/quiz',
      queryParameters: {
        'new_count': newC,
        'review_count': reviewC,
        'retry_count': retryC,
      },
    );
    return response.data;
  }

  // 2) 🌟 단일 문제 즉석 체크 및 GPT 힌트 수신 API (attemptCount 파라미터 추가 완료!)
  Future<Map<String, dynamic>> checkQuizAnswer(int sentenceId, String userAnswer, int attemptCount) async {
    final response = await ApiService.dio.post(
      '/vocabulary/quiz/check',
      data: {
        'sentence_id': sentenceId,
        'user_answer': userAnswer,
        'attempt_count': attemptCount, // 🔥 백엔드로 시도 횟수 전송!
      },
    );
    return response.data;
  }

  // 3) 퀴즈 세션 최종 제출 및 채점 API
  Future<Map<String, dynamic>> submitQuizSession(List<Map<String, dynamic>> answers) async {
    final response = await ApiService.dio.post(
      '/vocabulary/quiz/session',
      data: {'answers': answers},
    );
    return response.data;
  }
}