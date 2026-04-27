import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'; // DioException 처리를 위해 추가
import '../models/home_summary_model.dart';
import 'package:vipa/api/api_service.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var summary = Rxn<HomeSummary>();

  @override
  void onInit() {
    super.onInit();
    fetchHomeSummary();
  }

  Future<void> fetchHomeSummary() async {
    try {
      isLoading(true);
      debugPrint("🚀 [STEP 1] 홈 데이터 요청 시작");

      // 1. 요청 전 헤더 확인 (인터셉터에서 잘 들어갔는지 확인용)
      final response = await ApiService.dio.get('/home/summary');

      debugPrint("✅ [STEP 2] 서버 응답 도착 (Status: ${response.statusCode})");
      debugPrint("📦 [STEP 3] 응답 데이터 원본: ${response.data}");

      if (response.data != null) {
        try {
          // 2. 모델 변환 시도
          summary.value = HomeSummary.fromJson(response.data);
          debugPrint("✨ [STEP 4] 모델 변환 성공: ${summary.value?.nickname} 님 환영합니다.");
        } catch (parseError) {
          debugPrint("⚠️ [PARSE ERROR] 모델 변환 실패: $parseError");
          debugPrint("👉 데이터 형식이 모델(HomeSummary)과 일치하는지 확인하세요.");
        }
      } else {
        debugPrint("❓ [EMPTY] 서버에서 전달된 데이터가 null입니다.");
      }
      
    } catch (e) {
      // 3. 에러 상세 분석
      if (e is DioException) {
        debugPrint("❌ [DIO ERROR] 상태 코드: ${e.response?.statusCode}");
        debugPrint("❌ [DIO ERROR] 에러 응답: ${e.response?.data}");
        if (e.response?.statusCode == 401) {
          debugPrint("💡 조치: 아직 로그인이 안 되었거나 토큰이 전송되지 않았습니다.");
        }
      } else {
        debugPrint("❌ [UNKNOWN ERROR] 알 수 없는 오류: $e");
      }
    } finally {
      isLoading(false);
      debugPrint("🔚 [STEP 5] 데이터 로딩 프로세스 종료");
    }
  }
}