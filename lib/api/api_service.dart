import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // [설정] 현재 사용할 서버 주소를 여기서 하나만 선택하세요.
  // static const String baseUrl = "http://192.168.0.12:8000/api/v1"; // 1. 로컬 개발 서버 (포트번호 확인!)
  static const String baseUrl =
      "http://10.0.2.2:8000/api/v1"; // 2. 실제 폰 테스트용 IP
  // static const String baseUrl = "https://api.vipa.com/api/v1";     // 3. 배포 서버

  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 13),
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
