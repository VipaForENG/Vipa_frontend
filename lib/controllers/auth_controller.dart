import 'package:dio/dio.dart';
import '../api/api_service.dart';
import 'package:flutter/foundation.dart'; // debugPrint를 위해 필요합니다.
import '../services/auth_service.dart';
import 'package:get_storage/get_storage.dart'; // [추가] 토큰 저장을 위해 추가
import 'home_controller.dart';
import 'package:get/get.dart';


class AuthController {
  // [추가] 토큰 저장을 위한 인스턴스 추가
  static final _storage = GetStorage();
  static const String _tokenKey = 'access_token';
  
  // [추가] 홈 데이터를 다시 불러오도록 지시하는 공통 메서드
  static void _refreshHomeData() {
    try {
      if (Get.isRegistered<HomeController>()) {
        debugPrint("🔔 [AUTH] 로그인 성공! 홈 데이터를 다시 불러옵니다.");
        Get.find<HomeController>().fetchHomeSummary();
      }
    } catch (e) {
      debugPrint("⚠️ HomeController가 아직 등록되지 않았습니다.");
    }
  }
  

  static Future<String?> signUp({
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
          "is_social": 0,
          "social_role": 0,
        },
      );

      // 성공(200, 201) 시 에러가 없다는 의미로 null 반환
      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }
      return "알 수 없는 오류가 발생했습니다.";
    } on DioException catch (e) {
      // 🔥 서버에서 보낸 구체적인 에러 메시지("detail")가 있으면 반환, 없으면 기본 메시지
      final String? serverMessage = e.response?.data is Map 
          ? e.response?.data['detail'] 
          : e.message;
      
      debugPrint("❌ 회원가입 API 에러: $serverMessage");
      return serverMessage ?? "회원가입 요청 중 오류가 발생했습니다.";
    } catch (e) {
      debugPrint("❌ 시스템 에러: $e");
      return "시스템 오류가 발생했습니다.";
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
        // [추가] 로그인 성공 시 토큰 저장 로직 추가
        final token = response.data['access_token'];
        await _storage.write('access_token', token);

        _refreshHomeData();

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
        // [추가] 구글 로그인 성공 시 토큰 저장 로직 추가
        final token = response.data['access_token'];
        await _storage.write('access_token', token);

        _refreshHomeData();

        return response
            .data; // {"access_token": "VIPA_JWT...", "token_type": "bearer"} 반환
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
        // [추가] 카카오 로그인 성공 시 토큰 저장 로직 추가
        final token = response.data['access_token'];
        await _storage.write('access_token', token);
        _refreshHomeData();
        return response
            .data; // {"access_token": "VIPA_JWT...", "token_type": "bearer"} 반환
      }
      return null;
    } on DioException catch (e) {
      debugPrint("❌ 백엔드 카카오 로그인 API 에러: ${e.response?.data ?? e.message}");
      return null;
    }
  }


// --- 회원 탈퇴 ---
  static Future<bool> withdrawUser() async {
    try {
      final response = await ApiService.dio.delete("/users/withdraw");
      if (response.statusCode == 200) {
        await _storage.remove(_tokenKey); // StorageService 대신 _storage 직접 사용
        await _storage.remove('user_data');
        return true;
      }
      return false;
    } on DioException catch (e) {
      debugPrint("❌ 탈퇴 API 에러: ${e.response?.data}");
      return false;
    }
  }

  // --- 비밀번호 변경 ---
  static Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await ApiService.dio.patch("/users/mypage/change-password", 
          data: {"old_password": oldPassword, "new_password": newPassword});
      return response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint("❌ 비번 변경 API 에러: ${e.response?.data}");
      return false;
    }
  }
}