import 'dart:io';
import 'package:flutter/foundation.dart';

/// VIPA 프로젝트 API 설정 관리 파일
class ApiConfig {
  // [로컬 개발용 포트]
  static const String _port = "8000";

  // [환경 전환 플래그] 
  // true면 로컬 FastAPI 서버, false면 Render 배포 서버로 연결됩니다.
  static const bool isLocal = true; 

  // 배포된 Render 주소 기입
  static const String _prodUrl = "https://vipa-backend.onrender.com";

  // 스마트 플랫폼별 로컬 IP 감지 (안드로이드 에뮬레이터: 10.0.2.2, 데스크톱/웹/iOS: 127.0.0.1)
  static String get _localHost {
    if (kIsWeb) return "127.0.0.1";
    if (Platform.isAndroid) return "10.0.2.2";
    return "127.0.0.1";
  }

  static String get _localUrl => "http://$_localHost:$_port";

  // 최종 사용되는 API Base URL
  static String get baseUrl => "${isLocal ? _localUrl : _prodUrl}/api/v1";
}
