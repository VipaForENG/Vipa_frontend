import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'dart:math' as math;

import '../../routes/app_routes.dart';
import '../../design/snack_bar.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_service.dart';

/// [WaveBackground] 단색 파도 애니메이션 위젯
class WaveBackground extends StatelessWidget {
  final Color waveColor;
  final double waveHeightFactor;

  const WaveBackground({
    super.key,
    required this.waveColor,
    required this.waveHeightFactor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: waveHeightFactor),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, factor, child) {
        return _LoopingWave(
          waveColor: waveColor,
          heightFactor: factor,
        );
      },
    );
  }
}

class _LoopingWave extends StatefulWidget {
  final Color waveColor;
  final double heightFactor;

  const _LoopingWave({required this.waveColor, required this.heightFactor});

  @override
  State<_LoopingWave> createState() => _LoopingWaveState();
}

class _LoopingWaveState extends State<_LoopingWave> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: WavePainter(
            waveAnimation: _controller.value,
            waveColor: widget.waveColor,
            heightFactor: widget.heightFactor,
          ),
        );
      },
    );
  }
}

class WavePainter extends CustomPainter {
  final double waveAnimation;
  final Color waveColor;
  final double heightFactor;

  WavePainter({
    required this.waveAnimation,
    required this.waveColor,
    required this.heightFactor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = waveColor..style = PaintingStyle.fill;
    final Path path = Path();
    double baseHeight = size.height * (1.0 - heightFactor); 
    double waveAmplitude = 18.0;

    path.moveTo(0, baseHeight);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        baseHeight + math.sin((i / size.width * 2 * math.pi) + (waveAnimation * 2 * math.pi)) * waveAmplitude,
      );
    }
    path.lineTo(size.width, size.height + 100);
    path.lineTo(0, size.height + 100);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

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
      _currentWaveHeight = (_idFocusNode.hasFocus || _pwFocusNode.hasFocus) ? 0.45 : 0.35;
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

  void _processLoginResult(Map<String, dynamic>? result, {bool isSocial = false}) async {
    if (!mounted) return; 
    if (result != null) {
      final String? token = result['access_token'];
      if (token != null) await AuthService.saveToken(token);
      if (!mounted) return;

      final bool isTested = result['is_tested'] ?? false;
      VipaSnackBar.show(context, '성공적으로 로그인되었습니다!');
      Navigator.pushReplacementNamed(context, isTested ? AppRoutes.home : AppRoutes.levelTest);
    } else {
      VipaSnackBar.show(context, isSocial ? '소셜 로그인에 실패했습니다.' : '이메일 또는 비밀번호를 확인해주세요.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnyLoading = _isNormalLoading || _isGoogleLoading || _isKakaoLoading;
    const Color bgColor = Color(0xFFF5E4AD); 
    const Color waveColor = Color(0xFFFFF9E3);

    return Container(
      color: bgColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: WaveBackground(waveColor: waveColor, waveHeightFactor: _currentWaveHeight),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 85),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/images/LOGO-Photoroom.png', 
                          width: 95, 
                          height: 95,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 95),
                        ),
                      ),
                      const Text(
                        'VIPA',
                        style: TextStyle(color: Color(0xFF8B6B23), fontSize: 45, fontWeight: FontWeight.w900, letterSpacing: -1),
                      ),
                      const SizedBox(height: 55),
                      _buildUnderlineTextField(
                        controller: _idController, focusNode: _idFocusNode, hintText: '이메일', icon: RemixIcons.mail_fill
                      ),
                      const SizedBox(height: 20),
                      _buildUnderlineTextField(
                        controller: _pwController, focusNode: _pwFocusNode, hintText: '비밀번호', icon: RemixIcons.lock_password_fill, isObscure: true
                      ),
                      const SizedBox(height: 40),
                      _buildPrimaryButton(
                        text: _isNormalLoading ? '로그인 중...' : '로그인',
                        onPressed: isAnyLoading ? () {} : _handleLogin,
                        color: Colors.black87, textColor: Colors.white
                      ),
                      const SizedBox(height: 25),
                      _buildPrimaryButton(
                        text: _isGoogleLoading ? '처리 중...' : '구글로 로그인',
                        onPressed: isAnyLoading ? () {} : _handleGoogleLogin,
                        color: Colors.white, textColor: Colors.black87, hasBorder: true
                      ),
                      const SizedBox(height: 10),
                      _buildPrimaryButton(
                        text: _isKakaoLoading ? '처리 중...' : '카카오로 로그인',
                        onPressed: isAnyLoading ? () {} : _handleKakaoLogin,
                        color: const Color(0xFFFEE500), textColor: Colors.black87
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.signup), child: const Text('회원가입', style: TextStyle(color: Colors.black54))),
                          const Text('|', style: TextStyle(color: Colors.black12)),
                          TextButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.resetPassword), child: const Text('비밀번호 찾기', style: TextStyle(color: Colors.black54))),
                        ],
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        cursorColor: Colors.black87,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: Colors.black45),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 1)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2)),
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
            side: hasBorder ? const BorderSide(color: Colors.black87) : BorderSide.none,
          ),
        ),
        child: Text(text, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
      ),
    );
  }
}