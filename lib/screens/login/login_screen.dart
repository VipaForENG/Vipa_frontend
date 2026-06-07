import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isNormalLoading = false;
  bool _isGoogleLoading = false;
  bool _isKakaoLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      VipaSnackBar.show(context, '이메일과 비밀번호를 모두 입력해주세요.', isError: true);
      return;
    }

    setState(() => _isNormalLoading = true);
    final result = await AuthController.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _isNormalLoading = false);
    await _processLoginResult(result);
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    final result = await AuthController.loginWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);
    await _processLoginResult(result, isSocial: true);
  }

  Future<void> _handleKakaoLogin() async {
    setState(() => _isKakaoLoading = true);
    final result = await AuthController.loginWithKakao();
    if (!mounted) return;
    setState(() => _isKakaoLoading = false);
    await _processLoginResult(result, isSocial: true);
  }

  Future<void> _processLoginResult(
    Map<String, dynamic>? result, {
    bool isSocial = false,
  }) async {
    if (result == null) {
      VipaSnackBar.show(
        context,
        isSocial ? '소셜 로그인에 실패했습니다.' : '이메일 또는 비밀번호를 확인해주세요.',
        isError: true,
      );
      return;
    }

    final token = result['access_token'];
    if (token is String) await AuthService.saveToken(token);
    if (!mounted) return;

    final isTested = result['is_tested'] ?? false;
    VipaSnackBar.show(context, '성공적으로 로그인되었습니다!');
    Navigator.pushNamedAndRemoveUntil(
      context,
      isTested ? AppRoutes.home : AppRoutes.levelTest,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAnyLoading =
        _isNormalLoading || _isGoogleLoading || _isKakaoLoading;

    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 28),
          const VipaMark(size: 42),
          const SizedBox(height: 8),
          const Text(
            '로그인',
            style: TextStyle(
              color: Colors.black,
              fontSize: 31,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'VIPA와 함께 영어회화 실력을 늘려보세요!',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 42),
          AuthTextField(
            controller: _emailController,
            label: '이메일',
            hintText: '이메일',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            label: '비밀번호',
            hintText: '비밀번호',
            obscureText: true,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.resetPassword),
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '비밀번호를 잊으셨나요?',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
          AuthButton(
            text: _isNormalLoading ? '로그인 중...' : '로그인',
            onPressed: isAnyLoading ? null : _handleLogin,
          ),
          const SizedBox(height: 34),
          const DividerWithText(text: '소셜 계정 로그인'),
          const SizedBox(height: 18),
          SocialButton(
            text: _isKakaoLoading ? '처리 중...' : '카카오로 로그인',
            backgroundColor: const Color(0xFFFFDF14),
            icon: RemixIcons.chat_1_fill,
            iconColor: Colors.black,
            onPressed: isAnyLoading ? null : _handleKakaoLogin,
          ),
          const SizedBox(height: 11),
          SocialButton(
            text: _isGoogleLoading ? '처리 중...' : '구글로 로그인',
            backgroundColor: const Color(0xFFF3F4F7),
            leading: const GoogleMark(size: 18),
            onPressed: isAnyLoading ? null : _handleGoogleLogin,
          ),
          const SizedBox(height: 24),
          AuthFooterLink(
            prefix: '아직 계정이 없으신가요?',
            action: '회원가입',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}
