import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../controllers/auth_controller.dart';
import '../../design/animation_design.dart';
import '../../design/app_colors.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- 상태 관리 및 컨트롤러 ---
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _isNormalLoading = false;
  bool _isGoogleLoading = false;
  bool _isKakaoLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  // --- 비즈니스 로직 ---

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

  /// 로그인 결과 처리 및 네비게이션
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
    
    // 테스트 여부에 따라 페이지 이동
    Navigator.pushNamedAndRemoveUntil(
      context,
      isTested ? AppRoutes.home : AppRoutes.levelTest,
      (route) => false,
    );
  }

  // --- UI 구현 ---

  @override
  Widget build(BuildContext context) {
    final isAnyLoading = _isNormalLoading || _isGoogleLoading || _isKakaoLoading;
    const Color waveColor = AppColors.wave;

    return Scaffold(
      backgroundColor: waveColor, // 하단 단차 해결
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 85),
                    // 로고 애니메이션
                    FadeSlideTransition(
                      delay: 0.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/LOGO.png',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 95),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 이메일 입력
                    FadeSlideTransition(
                      delay: 0.2,
                      child: _buildUnderlineTextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        hintText: '이메일',
                        icon: RemixIcons.mail_fill,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 비밀번호 입력
                    FadeSlideTransition(
                      delay: 0.3,
                      child: _buildUnderlineTextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        hintText: '비밀번호',
                        icon: RemixIcons.lock_password_fill,
                        isObscure: true,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 로그인 버튼
                    FadeSlideTransition(
                      delay: 0.5,
                      child: _buildPrimaryButton(
                        text: _isNormalLoading ? '로그인 중...' : '로그인',
                        onPressed: isAnyLoading ? () {} : _handleLogin,
                        color: AppColors.primary,
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),
                    // 구글 로그인
                    FadeSlideTransition(
                      delay: 0.6,
                      child: _buildPrimaryButton(
                        text: _isGoogleLoading ? '처리 중...' : '구글로 로그인',
                        onPressed: isAnyLoading ? () {} : _handleGoogleLogin,
                        color: Colors.white,
                        textColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 카카오 로그인
                    FadeSlideTransition(
                      delay: 0.7,
                      child: _buildPrimaryButton(
                        text: _isKakaoLoading ? '처리 중...' : '카카오로 로그인',
                        onPressed: isAnyLoading ? () {} : _handleKakaoLogin,
                        color: const Color(0xFFFEE500),
                        textColor: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 회원가입 및 비밀번호 찾기
                    FadeSlideTransition(
                      delay: 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLinkButton('회원가입', () => Navigator.pushNamed(context, AppRoutes.signup)),
                          const Text('|', style: TextStyle(color: AppColors.primary)),
                          _buildLinkButton('비밀번호 찾기', () => Navigator.pushNamed(context, AppRoutes.resetPassword)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isObscure,
        cursorColor: AppColors.accent,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: AppColors.accent),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black87, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
  }) {
    return SizedBox(
      width: 300,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
      ),
    );
  }

  Widget _buildLinkButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text, style: const TextStyle(color: AppColors.primary)),
    );
  }
}