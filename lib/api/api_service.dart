import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // [추가] 토큰 읽기용
import 'api_config.dart'; // [추가] 설정 파일 임포트
import 'package:get/get.dart'; // [추가] Get 네비게이션 사용
import '../routes/app_routes.dart'; // [추가] 경로 참조

class ApiService {
  // baseUrl 설정 값 참조
  static const String baseUrl = ApiConfig.baseUrl;
  static const _storage = FlutterSecureStorage(); // [추가] 보안 저장소 인스턴스

  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      // validateStatus: (status) => status != null && status < 500, 
      // 주의: 401을 정상으로 넘기면 에러 처리가 어려워지므로 기본값 사용 권장
    ),
  )..interceptors.addAll([
      // 1. [추가] 인증 인터셉터: 모든 요청 헤더에 토큰 자동 주입
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 저장소에서 토큰 읽기
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            // 헤더에 Authorization 추가
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint("🔑 [AUTH] Access Token 주입 완료");
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            debugPrint("🚨 [AUTH] 토큰 만료 또는 인증 실패!");
            // 여기서 로그인 화면으로 이동시키는 로직을 추가할 수 있습니다.
            Get.offAllNamed(AppRoutes.login);
          }
          return handler.next(e);
        },
      ),
      // 2. 로그 인터셉터
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint("🌐 [DIO LOG] $obj"),
      ),
    ]);

    static Future<Map<String, dynamic>> getMyProfile() async {
    // 인증 인터셉터가 설정되어 있다면 헤더는 자동 포함됩니다.
    final response = await dio.get('/users/me'); 
    return response.data; 
  }
}
