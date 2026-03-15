import 'package:flutter/material.dart';

// [임포트] 각 화면들을 라우트에 연결하기 위해 가져옵니다.
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/signup/signup_screen.dart';
import '../screens/history/learning_history_screen.dart';
import '../screens/conversation/conversation_screen.dart';
import '../screens/grammar/grammar_screen.dart';
import '../screens/login/reset_password_screen.dart';
import '../screens/changepw/change_password_screen.dart';
import '../screens/mypage/subscription_screen.dart';
import '../screens/mypage/subscription_history_screen.dart';

/// [클래스] AppRoutes
/// 목적: 앱 내의 모든 페이지 경로(Route) 이름과 위젯을 매핑하여 중앙 관리합니다.
class AppRoutes {
  // [상수] 경로 이름 정의 (오타 방지 및 유지보수성 향상)
  static const String login = '/login';           // 로그인 화면
  static const String signup = '/signup';         // 회원가입 화면
  static const String home = '/';                 // 메인 홈 화면
  static const String history = '/history';       // 학습내역
  static const String conversation = '/conversation'; // 실전회화
  static const String vocabulary = '/vocabulary';     // 단어
  static const String grammar = '/grammar';           // 문법
  static const String resetPassword = '/reset-password'; // 비밀번호 찾기(이메일 인증)
  static const String changePassword = '/change-password'; // 비밀번호 변경(공통)
  static const String subscription = '/subscription';  // 구독제 충전 화면
  static const String subscriptionHistory = '/subscription-history';  // 구독제 충전/사용 내역 화면

  /// [함수] getRoutes
  /// 목적: 정의된 경로 이름과 실제 위젯(페이지)을 매핑한 맵을 반환합니다.
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // 1. 초기 진입 경로 및 인증 관련
      login: (context) => const LoginScreen(),
      signup: (context) => const SignupScreen(),
      resetPassword: (context) => const ResetPasswordScreen(),
      changePassword: (context) => const ChangePasswordScreen(),
      
      // 2. 메인 대시보드
      home: (context) => const HomeScreen(),

      // 3. 학습 기능 상세 페이지
      history: (context) => const LearningHistoryScreen(),
      conversation: (context) => const ConversationScreen(),
      grammar: (context) => const GrammarScreen(),


      subscription: (context) => const SubscriptionScreen(),
      subscriptionHistory: (context) => const SubscriptionHistoryScreen(),
    };
  }
}