import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // [설정] 현재 사용할 서버 주소를 여기서 하나만 선택하세요.
  static const String baseUrl =
      "http://10.38.220.116:8000/api/v1"; // 2. 안드로이드 에뮬레이터 테스트용 IP

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
            contentType: 'application/json',

            validateStatus: (status) => status! < 500,
          ),
        )
        // [중요] 개발 중에는 터미널에 통신 로그가 찍혀야 디버깅이 됩니다.
        ..interceptors.add(
          LogInterceptor(
            requestBody: true,
            responseBody: true,
            logPrint: (obj) => debugPrint("🌐 [DIO LOG] $obj"),
          ),
        );
}