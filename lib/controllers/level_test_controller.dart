import 'package:dio/dio.dart';
import '../api/api_service.dart';
import 'package:flutter/foundation.dart'; // debugPrint를 위해 필요합니다.
import '../services/auth_service.dart';


class LevelTestController {
  /// 1. 레벨 테스트 문제 가져오기
  static Future<List<dynamic>?> getLevelTestQuestions() async {
    try {
      final response = await ApiService.dio.get("/level-test/questions");
      if (response.statusCode == 200) {
        // 백엔드 응답 구조: {"questions": [...]}
        return response.data['questions'];
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ 레벨 테스트 문제 로드 에러: ${e.response?.data ?? e.message}");
      return null;
    }
  }

  /// 2. 레벨 테스트 결과 제출 및 평가
  static Future<bool> submitLevelTest(List<String> answers) async {
    try {
      // 1. 저장된 토큰 가져오기
      final String? token = await AuthService.getToken();

      // 토큰이 없으면 로그인이 안 된 상태이거나 저장이 안 된 것임
      if (token == null || token.isEmpty) {
        debugPrint("🚨 [AuthController] 토큰이 없습니다! 다시 로그인하세요.");
        return false;
      }

      debugPrint("🚀 [AuthController] 토큰을 가지고 제출 시도 중...");

      // 2. POST 요청 전송
      final response = await ApiService.dio.post(
        "/level-test/evaluate",
        data: {"user_answers": answers},
        options: Options(
          // ⭐ 헤더 설정을 여기에 직접, 명확하게 넣습니다.
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          // 401 에러가 나도 DioException을 던지지 않도록 설정 (로그 확인용)
          validateStatus: (status) => status! < 500,
        ),
      );

      debugPrint("✅ [AuthController] 서버 응답 코드: ${response.statusCode}");

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        debugPrint("❌ [AuthController] 인증 실패(401): 토큰이 만료되었거나 잘못되었습니다.");
        return false;
      }

      return false;
    } on DioException catch (e) {
      debugPrint(
        "❌ [AuthController] Dio 에러: ${e.response?.statusCode} - ${e.message}",
      );
      return false;
    } catch (e) {
      debugPrint("❌ [AuthController] 알 수 없는 에러: $e");
      return false;
    }
  }
}