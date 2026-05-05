import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../routes/app_routes.dart';
import '../../design/snack_bar.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_service.dart';
// 공용 애니메이션 임포트
import '../../design/animation_design.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final FocusNode _idFocusNode = FocusNode();
  final FocusNode _pwFocusNode = FocusNode();

  bool _isNormalLoading = false;
  bool _isGoogleLoading = false;
  bool _isKakaoLoading = false;
  double _currentWaveHeight = 0.35;

  @override
  void initState() {
    super.initState();
    _idFocusNode.addListener(_onFocusChange);
    _pwFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _currentWaveHeight = (_idFocusNode.hasFocus || _pwFocusNode.hasFocus)
          ? 0.45
          : 0.35;
    });
  }

  @override
  void dispose() {
    _idController.dispose();
    _pwController.dispose();
    _idFocusNode.dispose();
    _pwFocusNode.dispose();
    super.dispose();
  }

  // --- 로그인 로직 ---
  Future<void> _handleLogin() async {
    final email = _idController.text.trim();
    final password = _pwController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      VipaSnackBar.show(context, '이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }
    setState(() => _isNormalLoading = true);
    final result = await AuthController.login(email: email, password: password);
    if (!mounted) return;
    setState(() => _isNormalLoading = false);
    _processLoginResult(result);
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    final result = await AuthController.loginWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);
    _processLoginResult(result, isSocial: true);
  }

  Future<void> _handleKakaoLogin() async {
    setState(() => _isKakaoLoading = true);
    final result = await AuthController.loginWithKakao();
    if (!mounted) return;
    setState(() => _isKakaoLoading = false);
    _processLoginResult(result, isSocial: true);
  }

  void _processLoginResult(
    Map<String, dynamic>? result, {
    bool isSocial = false,
  }) async {
    if (!mounted) return;
    if (result != null) {
      final String? token = result['access_token'];
      if (token != null) await AuthService.saveToken(token);
      if (!mounted) return;

      final bool isTested = result['is_tested'] ?? false;
      VipaSnackBar.show(context, '성공적으로 로그인되었습니다!');
      Navigator.pushNamedAndRemoveUntil(
        context,
        isTested ? AppRoutes.home : AppRoutes.levelTest,
        (route) => false,
      );
    } else {
      VipaSnackBar.show(
        context,
        isSocial ? '소셜 로그인에 실패했습니다.' : '이메일 또는 비밀번호를 확인해주세요.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnyLoading =
        _isNormalLoading || _isGoogleLoading || _isKakaoLoading;

    // 🎨 색상 변수 설정
    const Color bgColor = Color(0xFFFFF9E5); // 상단 배경 (노란색)
    const Color waveColor = Color(0xFFffcbae); // 파도 및 하단 배경 (주황색)

    return Scaffold(
      // ✅ 1. 하단 단차 해결: Scaffold 배경을 파도 색상으로 설정
      backgroundColor: waveColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ✅ 2. 가장 밑바닥에 상단 배경색(노란색)을 꽉 채웁니다.
          Container(color: bgColor),

          // ✅ 3. 그 위에 파도를 그립니다. (파도 아래쪽은 자동으로 waveColor가 됨)
          Positioned.fill(
            child: WaveBackground(
              waveColor: waveColor,
              waveHeightFactor: _currentWaveHeight,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const SizedBox(height: 85),
                    FadeSlideTransition(
                      delay: 0.0,
                      child: Column(
                        children: [
                          ClipRRect(
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    FadeSlideTransition(
                      delay: 0.2,
                      child: _buildUnderlineTextField(
                        controller: _idController,
                        focusNode: _idFocusNode,
                        hintText: '이메일',
                        icon: RemixIcons.mail_fill,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideTransition(
                      delay: 0.3,
                      child: _buildUnderlineTextField(
                        controller: _pwController,
                        focusNode: _pwFocusNode,
                        hintText: '비밀번호',
                        icon: RemixIcons.lock_password_fill,
                        isObscure: true,
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeSlideTransition(
                      delay: 0.5,
                      child: _buildPrimaryButton(
                        text: _isNormalLoading ? '로그인 중...' : '로그인',
                        onPressed: isAnyLoading ? () {} : _handleLogin,
                        color: const Color(0xfff75f0b),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 25),
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
                    FadeSlideTransition(
                      delay: 0.9,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, AppRoutes.signup),
                            child: const Text(
                              '회원가입',
                              style: TextStyle(color: Color(0xfff75f0b)),
                            ),
                          ),
                          const Text(
                            '|',
                            style: TextStyle(color: Color(0xfff75f0b)),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              AppRoutes.resetPassword,
                            ),
                            child: const Text(
                              '비밀번호 찾기',
                              style: TextStyle(color: Color(0xfff75f0b)),
                            ),
                          ),
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
        cursorColor: Color(0xFFffa370),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: Color(0xFFffa370)),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black87, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFffa370), width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFffa370), width: 2),
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
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: 300,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: hasBorder
                ? const BorderSide(color: Colors.black87)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
