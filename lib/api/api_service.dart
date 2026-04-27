import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart'; // [추가] 토큰을 읽어오기 위해 필요합니다.

class ApiService {
  static const String baseUrl = "http://192.168.0.46:8000/api/v1";

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      validateStatus: (status) => status != null && status < 500,
    ),
  )
    // 1. 로그 인터셉터 (기존 유지)
    ..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint("🌐 [DIO LOG] $obj"),
      ),
    )
    // 2. 🔥 인증 토큰 자동 부착 인터셉터 (새로 통합)
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final storage = GetStorage();
          // AuthController 등에서 저장할 때 사용한 키값('access_token')과 일치해야 합니다.
          final String? token = storage.read('access_token');

          if (token != null && token.isNotEmpty) {
            // 서버가 기대하는 'Bearer {token}' 형식으로 헤더를 설정합니다.
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint("🔑 [DIO] 요청에 토큰 부착 완료");
          } else {
            debugPrint("⚠️ [DIO] 부착할 토큰이 없습니다.");
          }
          return handler.next(options); // 다음 요청 진행
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            debugPrint("🚨 [DIO] 401 Unauthorized 발생! 토큰이 만료되었거나 없을 수 있습니다.");
          }
          return handler.next(e);
        },
      ),
    );

  static Future<Map<String, dynamic>> talkToAi({
    required String userMessage,
    int? sessionId,
  }) async {
    try {
      final response = await dio.post(
        "/talk",
        data: {"user_message": userMessage, "session_id": sessionId},
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception("서버 응답 오류: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ApiService Error: $e");
      rethrow;
    }
  }
}