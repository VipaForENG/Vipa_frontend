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
          "is_social": 0, // 백엔드 DB 설계에 맞춘 정수값
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

  // 로그인 관련 auth_controller
  static Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.dio.post(
        "/users/login", // 백엔드 엔드포인트 경로 확인 필요 (/auth/login 인지 등)
        data: {"email": email, "password": password},
      );

      if (response.statusCode == 200) {
        // 성공 시 {"access_token": "...", "token_type": "bearer"} 반환
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ 로그인 API 에러: ${e.response?.data ?? e.message}");
      return null;
    }
  }

  //인증 코드 발송
  static Future<bool> sendRecoveryCode(String email) async {
    try {
      final response = await ApiService.dio.post(
        "/users/password-recovery/send-code",
        data: {"email": email},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("❌ 코드 발송 에러: ${e.response?.data ?? e.message}");
      return false;
    }
  }

  //인증 코드 검증
  static Future<bool> verifyRecoveryCode(String email, String code) async {
    try {
      final response = await ApiService.dio.post(
        "/users/password-recovery/verify-code",
        data: {"email": email, "code": code},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("❌ 코드 검증 에러: ${e.response?.data ?? e.message}");
      return false;
    }
  }

  //비밀번호 찾기
  static Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      final response = await ApiService.dio.patch(
        "/users/password-recovery/reset",
        data: {"email": email, "code": code, "new_password": newPassword},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("❌ 비번 재설정 에러: ${e.response?.data ?? e.message}");
      return false;
    }
  }
}
