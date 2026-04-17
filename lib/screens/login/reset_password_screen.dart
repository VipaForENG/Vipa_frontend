import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'dart:math' as math;

import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';

/// [WaveBackground] 공통 물결 위젯
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

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _inputController = TextEditingController(); 
  final FocusNode _emailFocusNode = FocusNode(); // 포커스 노드 추가

  bool _isLoading = false;
  double _currentWaveHeight = 0.35; // 초기 높이

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _currentWaveHeight = _emailFocusNode.hasFocus ? 0.45 : 0.35;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _inputController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  /// [함수] 인증 코드 발송 처리
  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      VipaSnackBar.show(context, '이메일을 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);
    bool success = await AuthController.sendRecoveryCode(email);
    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      VipaSnackBar.show(context, '인증 코드가 발송되었습니다.');
      _showAuthDialog();
    } else {
      if (!mounted) return;
      VipaSnackBar.show(context, '존재하지 않는 이메일이거나 발송에 실패했습니다.');
    }
  }

  /// [함수] 코드 검증 및 다음 단계 이동
  Future<void> _handleVerifyCode() async {
    final email = _emailController.text.trim();
    final code = _inputController.text.trim();

    if (code.length < 6) {
      VipaSnackBar.show(context, '6자리 코드를 입력해주세요.');
      return;
    }

    bool isVerified = await AuthController.verifyRecoveryCode(email, code);

    if (isVerified) {
      if (!mounted) return;
      Navigator.pop(context); 

      Navigator.pushNamed(
        context,
        AppRoutes.changePassword,
        arguments: {'email': email, 'code': code},
      );
    } else {
      if (!mounted) return;
      VipaSnackBar.show(context, '인증번호가 틀렸거나 만료되었습니다.');
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          '인증번호 입력',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _inputController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: '인증번호 6자리',
            counterText: "", 
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: _handleVerifyCode,
            child: const Text(
              '인증확인',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF5E4AD); 
    const Color waveColor = Color(0xFFFFF9E3);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: WaveBackground(
              waveColor: waveColor, 
              waveHeightFactor: _currentWaveHeight
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(RemixIcons.arrow_left_line, color: Colors.black87),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          const Icon(
                            RemixIcons.lock_password_line,
                            size: 80,
                            color: Color(0xFF8B6B23), // 포인트 컬러 브라운 적용
                          ),
                          const SizedBox(height: 30),
                          const Text(
                            '가입 시 사용한 이메일을 입력해주세요.\n인증번호를 보내드립니다.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 50),
                          SizedBox(
                            width: 300,
                            child: TextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode, // 포커스 노드 연결
                              decoration: const InputDecoration(
                                prefixIcon: Icon(RemixIcons.mail_fill, size: 20, color: Colors.black45),
                                prefixIconConstraints: BoxConstraints(minWidth: 35),
                                hintText: '이메일 주소',
                                hintStyle: TextStyle(color: Colors.black38),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black12, width: 1),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.black87, width: 2),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: 300,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleSendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                _isLoading ? '전송 중...' : '인증요청',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
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
          ),
        ],
      ),
    );
  }
}