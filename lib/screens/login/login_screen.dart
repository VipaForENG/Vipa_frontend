import 'package:flutter/material.dart';

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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isNormalLoading = false;
  bool _isGoogleLoading = false;
  bool _isKakaoLoading = false;

  bool get _isAnyLoading =>
      _isNormalLoading || _isGoogleLoading || _isKakaoLoading;

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
      VipaSnackBar.show(
        context,
        '이메일과 비밀번호를 모두 입력해주세요.',
        isError: true,
      );
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

    Navigator.pushNamedAndRemoveUntil(
      context,
      result['is_tested'] == true ? AppRoutes.home : AppRoutes.levelTest,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: [
                          const SizedBox(height: 72),
                          const VipaMark(size: 72),
                          const SizedBox(height: 22),
                          const Text(
                            '로그인',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 42,
                              height: 1,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1.4,
                            ),
                          ),
                          const SizedBox(height: 7),
                          const Text(
                            'VIPA의 환상적인 영어 학습을 느껴보세요!',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 62),
                          _LoginField(
                            label: '이메일',
                            hint: '이메일',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 13),
                          _LoginField(
                            label: '비밀번호',
                            hint: '비밀번호',
                            controller: _passwordController,
                            obscureText: true,
                          ),
                          const SizedBox(height: 9),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.resetPassword,
                              ),
                              child: const Text(
                                '비밀번호를 잊으셨나요?',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          _LoginButton(
                            text: _isNormalLoading ? '로그인 중...' : '로그인',
                            backgroundColor: AuthColors.primary,
                            foregroundColor: Colors.white,
                            onPressed: _isAnyLoading ? null : _handleLogin,
                            height: 56,
                            fontSize: 22,
                          ),
                          const SizedBox(height: 42),
                          const DividerWithText(text: '소셜 계정 로그인'),
                          const SizedBox(height: 20),
                          _LoginButton(
                            text: _isKakaoLoading ? '처리 중...' : '카카오로 로그인',
                            backgroundColor: const Color(0xFFFFE500),
                            foregroundColor: const Color(0xFF191919),
                            onPressed: _isAnyLoading ? null : _handleKakaoLogin,
                            leading: const Icon(
                              Icons.chat_bubble_rounded,
                              color: Color(0xFF191919),
                              size: 17,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _LoginButton(
                            text: _isGoogleLoading ? '처리 중...' : '구글로 로그인',
                            backgroundColor: const Color(0xFFF1F2F4),
                            foregroundColor: const Color(0xFF333333),
                            onPressed: _isAnyLoading ? null : _handleGoogleLogin,
                            leading: const GoogleMark(size: 18),
                          ),
                          const SizedBox(height: 64),
                          GestureDetector(
                            onTap: () =>
                                Navigator.pushNamed(context, AppRoutes.signup),
                            child: const Text.rich(
                              TextSpan(
                                text: '아직 계정이 없으신가요? ',
                                children: [
                                  TextSpan(
                                    text: '회원가입',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 38),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            cursorColor: AuthColors.primary,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFFB9BCC5),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xFFF2F3F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AuthColors.primary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  const _LoginButton({
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
    this.leading,
    this.height = 54,
    this.fontSize = 18,
  });

  final String text;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback? onPressed;
  final Widget? leading;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: backgroundColor,
          disabledBackgroundColor: backgroundColor.withValues(alpha: 0.65),
          foregroundColor: foregroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 6)],
            Text(
              text,
              style: TextStyle(
                color: foregroundColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
