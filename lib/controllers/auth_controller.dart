import 'package:dio/dio.dart';
import '../api/api_service.dart';
import 'package:flutter/foundation.dart'; // debugPrint를 위해 필요합니다.

class AuthController {
  static Future<bool> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      final response = await ApiService.dio.post(
        "/users/signup",
        data: {
          "email": email,
          "password": password,
          "nickname": nickname,
          "is_social": 0,    // 백엔드 DB 설계에 맞춘 정수값
          "social_role": 0,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      // 에러 발생 시 로그 확인용
      debugPrint("❌ 회원가입 API 에러: ${e.response?.data ?? e.message}");
      return false;
    }
  }
}