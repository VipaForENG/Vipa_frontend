import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart'; // 패키지 설치 필요: flutter pub add get_storage

class ApiService {
  // [설정] 현재 사용할 서버 주소를 여기서 하나만 선택하세요.
  static const String baseUrl = "http://192.168.0.77:8000/api/v1"; // 1. 엄인섭 집 개발 서버 (포트번호 확인!)
  // static const String baseUrl =
      // "http://10.45.209.240:8000/api/v1"; // 2. 안드로이드 에뮬레이터 테스트용 IP
  // static const String baseUrl = "https://api.vipa.com/api/v1";     // 3. 배포 서버
  //static const String baseUrl = "http://192.168.45.77:8000/api/v1";
  static final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 30),
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