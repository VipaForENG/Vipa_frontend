import 'package:dio/dio.dart';
import '../api/api_service.dart';
import '../services/auth_service.dart';
import '../models/level_test_model.dart';

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
      return null;
    }
  }

 /// 2. 레벨 테스트 결과 제출 및 평가 (수정됨)
  static Future<LevelTestResult?> submitLevelTest(List<String> answers) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null || token.isEmpty) return null;

      final response = await ApiService.dio.post(
        "/level-test/evaluate",
        data: {"user_answers": answers},
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return LevelTestResult.fromJson(response.data);
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}