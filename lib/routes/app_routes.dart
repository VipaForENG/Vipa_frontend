import 'package:flutter/material.dart';

// [모델] 데이터 전달에 필요한 모델 임포트
import '../models/conversation_category_model.dart';
import '../models/level_test_model.dart';

// [화면] 각 도메인별 화면 위젯 임포트
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/signup/signup_screen.dart';
import '../screens/login/reset_password_screen.dart';
import '../screens/login/verification_code_screen.dart';
import '../screens/changepw/change_password_screen.dart';
import '../screens/history/learning_history_screen.dart';
import '../screens/conversation/chat/conversation_chat_screen.dart';
import '../screens/conversation/category/sub_category_selection_screen.dart';
import '../screens/vocabulary/vocabulary_dashboard_screen.dart';
import '../screens/vocabulary/vocabulary_result_screen.dart';
import '../screens/vocabulary/vocabulary_screen.dart';
import '../screens/level_test/level_test_screen.dart';
import '../screens/level_test/level_test_result_screen.dart';

/// 앱 내 모든 화면 이동 경로를 관리하는 라우팅 클래스입니다.
/// named route 방식을 사용하여 화면 전환 로직을 중앙 집중화합니다.
class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String history = '/history';
  static const String conversation = '/conversation';
  static const String resetPassword = '/reset-password';
  static const String verificationCode = '/verification-code';
  static const String changePassword = '/change-password';
  static const String levelTest = '/level-test';
  static const String levelTestResult = '/level-test-result';
  static const String subCategory = '/sub-category';
  static const String vocabularyDashboard = '/vocabulary-dashboard';
  static const String vocabulary = '/vocabulary';
  static const String vocabularyResult = '/vocabulary-result';

  /// 라우트 설정에 따라 화면을 생성하고 애니메이션을 적용합니다.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case splash:
        return _buildFadeRoute(const SplashScreen(), settings);
      case login:
        return _buildFadeRoute(const LoginScreen(), settings);
      case signup:
        return _buildFadeRoute(const SignupScreen(), settings);

      // [비밀번호 찾기] 상황에 따라 이메일 주입 및 마이페이지 진입 여부 구분
      case resetPassword:
        if (args is Map<String, dynamic>) {
          return _buildFadeRoute(
            ResetPasswordScreen(
              initialEmail: args['email'] as String?,
              isFromMyPage: args['isFromMyPage'] == true,
            ),
            settings,
          );
        }
        return _buildFadeRoute(const ResetPasswordScreen(), settings);

      // [인증번호] 이메일 기반 인증 프로세스
      case verificationCode:
        if (args is String) {
          return _buildFadeRoute(VerificationCodeScreen(email: args), settings);
        }
        if (args is Map<String, dynamic> && args['email'] is String) {
          return _buildFadeRoute(
            VerificationCodeScreen(
              email: args['email'] as String,
              isFromMyPage: args['isFromMyPage'] == true,
            ),
            settings,
          );
        }
        // 예외 상황 시 로그인 화면으로 복귀하거나 안내 필요
        return _buildFadeRoute(const ResetPasswordScreen(), settings);

      case changePassword:
        if (args is Map<String, dynamic>) {
          return _buildFadeRoute(
            ChangePasswordScreen(isFromMyPage: args['isFromMyPage'] == true),
            settings,
          );
        }
        return _buildFadeRoute(const ChangePasswordScreen(), settings);

      case home:
        return _buildFadeRoute(const HomeScreen(), settings);
      case history:
        return _buildFadeRoute(
          LearningHistoryScreen(
            initialDetailType: args is HistoryDetailType ? args : null,
          ),
          settings,
        );

      // [대화 화면] SubCategory 객체 또는 ID 전달
      case conversation:
        if (args is SubCategory) {
          return _buildFadeRoute(
            ConversationChatScreen(subCatId: args.subCatId),
            settings,
          );
        }
        if (args is int) {
          return _buildFadeRoute(
            ConversationChatScreen(subCatId: args),
            settings,
          );
        }
        return _buildFadeRoute(
          const ConversationChatScreen(subCatId: 1),
          settings,
        );

      // [카테고리 선택] 메인 카테고리 ID 전달
      case subCategory:
        if (args is int) {
          return _buildFadeRoute(
            SubCategorySelectionScreen(mainCatId: args),
            settings,
          );
        }
        return _buildFadeRoute(
          const SubCategorySelectionScreen(mainCatId: 1),
          settings,
        );

      case vocabularyDashboard:
        return _buildFadeRoute(const VocabularyDashboardScreen(), settings);
      case vocabulary:
        return _buildFadeRoute(const VocabularyScreen(), settings);
      case vocabularyResult:
        return _buildFadeRoute(const VocabularyResultScreen(), settings);
      case levelTest:
        return _buildFadeRoute(const LevelTestScreen(), settings);

      // [레벨 테스트 결과] 결과 객체(LevelTestResult) 필수 확인
      case levelTestResult:
        if (args is LevelTestResult) {
          return _buildFadeRoute(LevelTestResultScreen(result: args), settings);
        }
        return _buildFadeRoute(
          const Scaffold(body: Center(child: Text('결과 데이터가 없습니다.'))),
          settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  /// Fade 애니메이션이 포함된 페이지 라우트 빌더 (일관된 화면 전환 효과)
  static PageRouteBuilder _buildFadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}
