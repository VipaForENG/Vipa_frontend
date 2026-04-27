import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // 서버 설정
  static const String baseUrl = "http://192.168.0.61:8000/api/v1";
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
    ),
  );

  // 🔴 여기가 핵심입니다. 이 부분이 정의되어 있어야 합니다!
  static Future<Map<String, dynamic>> talkToAi({
    required String userMessage,
    int? sessionId,
  }) async {
    try {
      final response = await dio.post(
        "/talk", // 백엔드 경로 확인 (필요시 /chat/talk 로 변경)
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
