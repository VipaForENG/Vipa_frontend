/// VIPA 프로젝트 API 설정 관리 파일
class ApiConfig {
  // 팀원마다 다른 IP를 쓸 경우 여기서만 수정하면 됩니다.
  static const String _localIp = "192.168.45.69";
  static const String _port = "8000";

  // 개발용(Local)과 운영용(Prod)을 분리할 수 있는 기초 구조
  static const String baseUrl = "http://$_localIp:$_port/api/v1";
}
