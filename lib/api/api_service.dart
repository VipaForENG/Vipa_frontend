import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart'; // 패키지 설치 필요: flutter pub add get_storage

class ApiService {
  // [설정] 현재 사용할 서버 주소를 여기서 하나만 선택하세요.
  static const String baseUrl = "http://192.168.0.46:8000/api/v1"; // 1. 엄인섭 집 개발 서버 (포트번호 확인!)
  // static const String baseUrl =
      // "http://10.45.209.240:8000/api/v1"; // 2. 안드로이드 에뮬레이터 테스트용 IP
  // static const String baseUrl = "https://api.vipa.com/api/v1";     // 3. 배포 서버
  //static const String baseUrl = "http://192.168.45.77:8000/api/v1";
  
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      contentType: 'application/json',
      validateStatus: (status) => status! < 500,
    ),
  )
    // 1. [추가] 인증 인터셉터: 요청 보낼 때마다 토큰이 있으면 헤더에 부착
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final storage = GetStorage();
          final String? token = storage.read('access_token');

          if (token != null && token.isNotEmpty) {
            // 헤더에 Authorization 추가
            options.headers['Authorization'] = 'Bearer $token';
            debugPrint("🗝️ [AUTH] 토큰을 헤더에 부착했습니다.");
          } else {
            debugPrint("⚠️ [AUTH] 저장된 토큰이 없어 빈 헤더로 요청합니다.");
          }
          return handler.next(options); // 다음 단계로 진행
        },
      ),
    )
    // 2. 로그 인터셉터 (기존 유지)
    ..interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint("🌐 [DIO LOG] $obj"),
      ),
    );
}