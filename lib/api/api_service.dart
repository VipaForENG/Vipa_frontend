import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart'; // 👈 AuthService 임포트

class ApiService {
  static const String baseUrl = "http://192.168.0.61:8000/api/v1";

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            contentType: 'application/json',
            validateStatus: (status) => status != null && status < 500,
          ),
        )
        ..interceptors.add(
          // 1. 요청 보낼 때마다 자동으로 토큰을 넣어주는 인터셉터 추가
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await AuthService.getToken();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
              return handler.next(options);
            },
          ),
        )
        ..interceptors.add(
          // 2. 로그 확인용
          LogInterceptor(
            requestBody: true,
            responseBody: true,
            logPrint: (obj) => debugPrint("🌐 [DIO LOG] $obj"),
          ),
        );

  static Future<Map<String, dynamic>> talkToAi({
    required String userMessage,
    int? sessionId,
  }) async {
    try {
      // 3. 서버가 요구하는 스키마에 맞게 데이터 구성
      final Map<String, dynamic> data = {"user_message": userMessage};
      if (sessionId != null) {
        data["session_id"] = sessionId;
      }

      final response = await dio.post("/chat/talk", data: data);

      // 4. 응답 확인
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception("로그인이 만료되었습니다. 다시 로그인하세요.");
      } else {
        throw Exception("서버 응답 오류: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("ApiService Error: $e");
      rethrow;
    }
  }
}
