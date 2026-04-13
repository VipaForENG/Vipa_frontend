import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart'; 
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ 추가됨

class AuthService {
  // =========================================
  // 🟢 구글 로그인 (v7.0 이상 최신 문법 + 서버 ID 통합)
  // =========================================
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  static bool _isGoogleInitialized = false;

  /// 구글 SDK 초기화 (백엔드 통신을 위한 serverClientId 설정)
  static Future<void> _ensureGoogleInitialized() async {
    if (!_isGoogleInitialized) {
      // ✅ .env에서 웹 클라이언트 ID를 가져와 서버 측 인증을 위해 넘겨줍니다.
      await _googleSignIn.initialize(
        serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
      );
      _isGoogleInitialized = true;
    }
  }

  /// 구글 SDK를 통해 액세스 토큰 획득
  static Future<String?> getGoogleAccessToken() async {
    try {
      await _ensureGoogleInitialized();

      // 1. 구글 인증 요청
      final googleUser = await _googleSignIn.authenticate(
        scopeHint: ['email', 'profile'], 
      );

      // 2. 권한 클라이언트 획득
      final authClient = googleUser.authorizationClient;
      
      // 3. 현재 권한 확인 및 부족 시 추가 요청
      var authorization = await authClient.authorizationForScopes(['email', 'profile']);
      authorization ??= await authClient.authorizeScopes(['email', 'profile']);

      // 4. 백엔드로 보낼 accessToken 반환
      return authorization.accessToken; 
    } catch (e) {
      debugPrint("❌ 구글 SDK 로그인 에러 또는 취소: $e");
      return null;
    }
  }


  // =========================================
  // 🟡 카카오 로그인 (최신 SDK 문법)
  // =========================================

  /// 카카오 SDK를 통해 액세스 토큰 획득
  static Future<String?> getKakaoAccessToken() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      OAuthToken token;

      if (isInstalled) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (e) {
          if (e is PlatformException && e.code == 'CANCELED') {
            return null; 
          }
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      
      return token.accessToken; // 카카오 access_token 반환
    } catch (e) {
      if (e is PlatformException && e.code == 'CANCELED') {
        return null;
      }
      debugPrint("❌ 카카오 SDK 로그인 에러 또는 취소: $e");
      return null;
    }
  }
}