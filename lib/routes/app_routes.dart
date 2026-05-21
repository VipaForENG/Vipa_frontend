import 'package:flutter/material.dart';

import '../models/conversation_category_model.dart';
import '../models/level_test_model.dart';
import '../screens/changepw/change_password_screen.dart';
import '../screens/conversation/category/sub_category_selection_screen.dart';
import '../screens/conversation/chat/conversation_chat_screen.dart';
import '../screens/history/learning_history_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/level_test/level_test_result_screen.dart';
import '../screens/level_test/level_test_screen.dart';
import '../screens/login/login_screen.dart';
import '../screens/login/reset_password_screen.dart';
import '../screens/mypage/subscription_history_screen.dart';
import '../screens/mypage/subscription_screen.dart';
import '../screens/signup/signup_screen.dart';
import '../screens/vocabulary/vocabulary_dashboard_screen.dart';
import '../screens/vocabulary/vocabulary_result_screen.dart';
import '../screens/vocabulary/vocabulary_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/';
  static const String history = '/history';
  static const String conversation = '/conversation';
  static const String resetPassword = '/reset-password';
  static const String changePassword = '/change-password';
  static const String subscription = '/subscription';
  static const String subscriptionHistory = '/subscription-history';
  static const String levelTest = '/level-test';
  static const String levelTestResult = '/level-test-result';
  static const String subCategory = '/sub-category';
  static const String vocabularyDashboard = '/vocabulary-dashboard';
  static const String vocabulary = '/vocabulary';
  static const String vocabularyResult = '/vocabulary-result';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case login:
        return _buildFadeRoute(const LoginScreen(), settings);
      case signup:
        return _buildFadeRoute(const SignupScreen(), settings);
      case resetPassword:
        return _buildFadeRoute(const ResetPasswordScreen(), settings);
      case changePassword:
        return _buildFadeRoute(const ChangePasswordScreen(), settings);
      case home:
        return _buildFadeRoute(const HomeScreen(), settings);
      case history:
        return _buildFadeRoute(const LearningHistoryScreen(), settings);
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
      case subscription:
        return _buildFadeRoute(const SubscriptionScreen(), settings);
      case subscriptionHistory:
        return _buildFadeRoute(const SubscriptionHistoryScreen(), settings);
      case levelTest:
        return _buildFadeRoute(const LevelTestScreen(), settings);
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
