import 'package:dio/dio.dart';
import '../api/api_service.dart';
import 'package:flutter/foundation.dart'; // debugPrint를 위해 필요합니다.
import '../services/auth_service.dart';

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
  /// 구글 로그인 프로세스 (SDK 토큰 발급 -> 백엔드 검증)
  static Future<Map<String, dynamic>?> loginWithGoogle() async {
    try {
      // 1. 프론트엔드 - 구글 SDK로 access_token 획득
      final String? googleToken = await AuthService.getGoogleAccessToken();
      if (googleToken == null) return null; // 로그인 취소

      // 2. 백엔드로 토큰 전달 (엔드포인트 경로 /api/v1/auth/login/google 등 확인 필요)
      final response = await ApiService.dio.post(
        "/auth/login/google", 
        data: {"access_token": googleToken},
      );

      if (response.statusCode == 200) {
        return response.data; // {"access_token": "VIPA_JWT...", "token_type": "bearer"} 반환
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ 백엔드 구글 로그인 API 에러: ${e.response?.data ?? e.message}");
      return null;
    }
  }

  /// 카카오 로그인 프로세스 (SDK 토큰 발급 -> 백엔드 검증)
  static Future<Map<String, dynamic>?> loginWithKakao() async {
    try {
      // 1. 프론트엔드 - 카카오 SDK로 access_token 획득
      final String? kakaoToken = await AuthService.getKakaoAccessToken();
      if (kakaoToken == null) return null; // 로그인 취소

      // 2. 백엔드로 토큰 전달
      final response = await ApiService.dio.post(
        "/auth/login/kakao", 
        data: {"access_token": kakaoToken},
      );

      if (response.statusCode == 200) {
        return response.data; // {"access_token": "VIPA_JWT...", "token_type": "bearer"} 반환
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ 백엔드 카카오 로그인 API 에러: ${e.response?.data ?? e.message}");
      return null;
    }
  }
}
