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
    
    // 폰트나 전체 버튼의 최대 너비를 제한하여 시안의 여백을 맞춥니다.
    const double contentMaxWidth = 340;

    return Scaffold(
      backgroundColor: Colors.white, 
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  
                  // 1. 로고 및 타이틀 영역
                  FadeSlideTransition(
                    delay: 0.0,
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/LOGO.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image, size: 80, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '로그인',
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            letterSpacing: -1.5, // 자간을 확 좁혀 시안 느낌 살림
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'VIPA의 환상적인 영어 학습을 느껴보세요!',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 45),

                  // 중앙 내용물 너비 제한 컨테이너
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: contentMaxWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 2. 이메일 입력
                        FadeSlideTransition(
                          delay: 0.2,
                          child: _buildInputField(
                            label: '이메일',
                            controller: _emailController,
                            focusNode: _emailFocusNode,
                            hintText: '이메일',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // 3. 비밀번호 입력
                        FadeSlideTransition(
                          delay: 0.3,
                          child: _buildInputField(
                            label: '비밀번호',
                            controller: _passwordController,
                            focusNode: _passwordFocusNode,
                            hintText: '비밀번호',
                            isObscure: true,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 4. 비밀번호 찾기 (우측 정렬)
                        FadeSlideTransition(
                          delay: 0.4,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.resetPassword),
                              child: const Text(
                                '비밀번호를 잊으셨나요?',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 5. 일반 로그인 버튼
                        FadeSlideTransition(
                          delay: 0.5,
                          child: _buildPrimaryButton(
                            text: _isNormalLoading ? '로그인 중...' : '로그인',
                            onPressed: isAnyLoading ? () {} : _handleLogin,
                            color: const Color(0xFFFF5A3A), 
                            textColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 6. 소셜 로그인 구분선
                        FadeSlideTransition(
                          delay: 0.6,
                          child: Row(
                            children: [
                              const Expanded(child: Divider(color: Colors.black26, thickness: 0.5)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14),
                                child: Text(
                                  '소셜 계정 로그인',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                ),
                              ),
                              const Expanded(child: Divider(color: Colors.black26, thickness: 0.5)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // 7. 카카오 로그인 버튼
                        FadeSlideTransition(
                          delay: 0.7,
                          child: _buildSocialButton(
                            text: _isKakaoLoading ? '처리 중...' : '카카오로 로그인',
                            onPressed: isAnyLoading ? () {} : _handleKakaoLogin,
                            color: const Color(0xFFFEE500),
                            textColor: Colors.black87,
                            icon: const Icon(Icons.chat_bubble, color: Color(0xFF381E1F), size: 20), // 카카오 갈색에 가깝게
                          ),
                        ),
                        const SizedBox(height: 15),

                        // 8. 구글 로그인 버튼
                        FadeSlideTransition(
                          delay: 0.8,
                          child: _buildSocialButton(
                            text: _isGoogleLoading ? '처리 중...' : '구글로 로그인',
                            onPressed: isAnyLoading ? () {} : _handleGoogleLogin,
                            color: const Color(0xFFF4F5F7),
                            textColor: Colors.black87,
                            // 시안의 알록달록한 구글 로고 느낌을 주기 위해 Color 폰트 아이콘 대신
                            // 에셋 이미지가 있다면 Image.asset('assets/images/google_logo.png')를 사용하세요.
                            // 일단 가장 유사한 아이콘으로 배치해 두었습니다.
                            icon: const Icon(RemixIcons.google_fill, color: Colors.redAccent, size: 22),
                          ),
                        ),
                        const SizedBox(height: 60),

                        // 9. 하단 회원가입 링크
                        FadeSlideTransition(
                          delay: 0.9,
                          child: Align(
                            alignment: Alignment.center,
                            child: GestureDetector(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                              child: RichText(
                                text: const TextSpan(
                                  text: '아직 계정이 없으신가요? ',
                                  style: TextStyle(color: Colors.black87, fontSize: 13),
                                  children: [
                                    TextSpan(
                                      text: '회원가입',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w900, // 더 굵게
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Helper Methods ---

  /// 상단 라벨이 있는 박스 형태의 TextField
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700, // 살짝 더 굵게
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 52, // 시안의 두툼한 높이
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            obscureText: isObscure,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 15),
              filled: true,
              fillColor: const Color(0xFFF4F5F9), 
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), // 수직 패딩 조정으로 정렬
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12), // 모서리를 더 둥글게
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 메인 로그인 버튼
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54, // 높이를 조금 더 줌
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // 모서리 둥글게
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }

  /// 소셜 로그인 버튼 (아이콘 포함)
  Widget _buildSocialButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
    required Widget icon,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: textColor), // 약간 덜 굵게
            ),
          ],
        ),
      ),
    );
  }
}