import 'package:flutter/material.dart';

// [임포트] 각 화면 위젯들을 가져옵니다.
import '../screens/home/home_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/signup/signup_screen.dart';
import '../screens/history/learning_history_screen.dart';
import '../screens/conversation/chat/conversation_chat_screen.dart';
import '../screens/grammar/grammar_screen.dart';
import '../screens/login/reset_password_screen.dart';
import '../screens/changepw/change_password_screen.dart';
import '../screens/mypage/subscription_screen.dart';
import '../screens/mypage/subscription_history_screen.dart';
import '../screens/level_test/level_test_screen.dart';
import '../screens/level_test/level_test_result_screen.dart';
import '../models/level_test_model.dart';
import '../screens/conversation/category/sub_category_selection_screen.dart';

/// [클래스] AppRoutes
/// 앱 내의 모든 경로 설정 및 전환 애니메이션을 담당하는 클래스입니다.
class AppRoutes {
  // [상수] 페이지 경로 이름 정의
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String history = '/history';
  static const String conversation = '/conversation';
  static const String vocabulary = '/vocabulary';
  static const String grammar = '/grammar';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String subscription = '/subscription';
  static const String subscriptionHistory = '/subscription-history';
  static const String levelTest = '/level-test';
  static const String levelTestResult = '/level-test-result';
  static const String subCategory = '/sub-category'; // [추가] 소분류 선택 화면
  /// [함수] onGenerateRoute
  /// 설정된 이름(name)에 따라 해당되는 페이지 위젯을 생성하고 애니메이션을 입힙니다.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // 이동 시 전달된 데이터가 있다면 저장합니다.
    // ignore: unused_local_variable
  final args = settings.arguments;
    switch (settings.name) {
      case login:
        return _buildFadeRoute(const LoginScreen(), settings);
      case signup:
        return _buildFadeRoute(const SignupScreen(), settings);
      case resetPassword:
        return _buildFadeRoute(const ResetPasswordScreen(), settings);
      case changePassword:
        // [에러 해결] 만약 ChangePasswordScreen에 arguments 매개변수가 없다면
        // 아래와 같이 기본 호출 방식으로 수정해야 합니다.
        return _buildFadeRoute(const ChangePasswordScreen(), settings);
      case home:
        return _buildFadeRoute(const HomeScreen(), settings);
      case history:
        return _buildFadeRoute(const LearningHistoryScreen(), settings);
      case conversation:
        // [L3 흐름 제어] 넘어온 데이터가 int 타입인지 검증합니다.
        if (args is int) {
          return _buildFadeRoute(ConversationChatScreen(mainCatId: args), settings);
        }
        // 데이터가 누락된 경우를 대비한 방어 코드 (Default: 1)
        debugPrint('🚨 [Routing Error] conversation 경로에 ID가 누락되었습니다.');
        return _buildFadeRoute(const ConversationChatScreen(mainCatId: 1), settings);
      
      case subCategory:
        // [L3 흐름 제어] 넘어온 데이터가 int 타입인지 검증합니다.
        if (args is int) {
          return _buildFadeRoute(SubCategorySelectionScreen(mainCatId: args), settings);
        }
        // 데이터가 누락된 경우를 대비한 방어 코드 (Default: 1)
        debugPrint('🚨 [Routing Error] subCategory 경로에 ID가 누락되었습니다.');
        return _buildFadeRoute(const SubCategorySelectionScreen(mainCatId: 1), settings);
      case grammar:
        return _buildFadeRoute(const GrammarScreen(), settings);
      case subscription:
        return _buildFadeRoute(const SubscriptionScreen(), settings);
      case subscriptionHistory:
        return _buildFadeRoute(const SubscriptionHistoryScreen(), settings);
      case levelTest:
        return _buildFadeRoute(const LevelTestScreen(), settings);
      case levelTestResult:
        // 1. 매개변수(args)가 우리가 원하는 모델 타입인지 확인
        if (args is LevelTestResult) {
          // 2. 맞다면 생성자를 통해 데이터를 직접 전달
          return _buildFadeRoute(LevelTestResultScreen(result: args), settings);
        }
        // 3. 데이터가 비정상적일 때의 예외 처리 (이게 없으면 아래가 dead_code가 될 수 있음)
        return _buildFadeRoute(const Scaffold(body: Center(child: Text("결과 데이터가 없습니다."))), settings);

      default:
        // 정의되지 않은 경로인 경우 표시할 예외 화면
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  /// [함수] _buildFadeRoute
  /// 페이지 전환 시 배경색 깜빡임을 방지하기 위해 
  /// 화면이 부드럽게 겹치며 나타나는 Fade(페이드) 애니메이션을 적용합니다.
  static PageRouteBuilder _buildFadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      // [설정] 목적지 페이지 위젯
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      // [설정] 애니메이션 효과 (투명도 조절)
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation, // 0.0에서 1.0으로 투명도 변화
          child: child,
        );
      },
      // [설정] 애니메이션 지속 시간 (0.20초)
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}