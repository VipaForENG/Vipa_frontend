import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = "http://192.168.0.61:8000/api/v1";

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            contentType: 'application/json',
            // validateStatus는 함수형태로 정확하게 작성해야 합니다.
            validateStatus: (status) => status != null && status < 500,
          ),
        )
        ..interceptors.add(
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
