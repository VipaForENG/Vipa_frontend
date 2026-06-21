/// VIPA 프로젝트 API 설정 관리 파일
class ApiConfig {
  // [로컬 개발용 변수]
  static const String _localIp = "192.168.45.77";
  static const String _port = "8000";

  // [환경 전환 플래그] 
  // true면 로컬 서버, false면 Render 배포 서버로 연결됩니다.
  static const bool isLocal = false; 

  // 배포된 Render 주소 기입 (https 필수, 포트 번호 없음)
  static const String _prodUrl = "https://vipa-backend.onrender.com";
  static const String _localUrl = "http://$_localIp:$_port";

  // 최종 사용되는 API Base URL
  static const String baseUrl = "${isLocal ? _localUrl : _prodUrl}/api/v1";
}
