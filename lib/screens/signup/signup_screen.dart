import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'dart:math' as math;
import '../../routes/app_routes.dart';
import '../../Design/snack_bar.dart';
import '../../controllers/auth_controller.dart';

// ----------------------------------------------------------------             
// 1. 애니메이션 보조 위젯: _FadeSlideTransition
// ----------------------------------------------------------------             
/// 위젯을 투명도(Opacity)와 위치 이동(Translate)을 이용해 부드럽게 등장시킵니다.
class _FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final double delay; // 애니메이션 시작 지연 시간

  const _FadeSlideTransition({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      // 시간을 1.2초로 설정하여 여유롭고 우아하게 등장
      duration: const Duration(milliseconds: 1250),
      // 시작 시점을 delay 값에 따라 조절 (Curves.easeOutExpo로 고급스러운 감속 효과)
      curve: Interval(delay, 1.0, curve: Curves.easeOutExpo),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            // 아래에서 위로 40px 이동하며 등장
            offset: Offset(0, 40 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// ----------------------------------------------------------------             
// 2. 배경 애니메이션: WaveBackground & WavePainter
// ----------------------------------------------------------------             
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
      duration: const Duration(milliseconds: 1250),
      curve: Curves.easeInOutCubic,
      builder: (context, factor, child) {
        return _LoopingWave(waveColor: waveColor, heightFactor: factor);
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
    // 파도가 5초 주기로 천천히 일렁이도록 설정
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
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
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height + 1000);
    // 배경에 그라데이션을 적용하여 깊이감 부여
    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withValues(alpha: 0.5),
        const Color(0xFFFDF5E6),
        const Color(0xFFF5E4AD), 
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    Paint paint = Paint()..shader = gradient.createShader(rect)..style = PaintingStyle.fill;
    Path path = Path();
    double baseHeight = size.height * (1.0 - heightFactor);
    double waveAmplitude = 15.0; // 파도 진폭

    path.moveTo(0, baseHeight);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        baseHeight + math.sin((i / size.width * 2 * math.pi) + (waveAnimation * 2 * math.pi)) * waveAmplitude,
      );
    }
    path.lineTo(size.width, size.height + 1000);
    path.lineTo(0, size.height + 1000);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// ----------------------------------------------------------------             
// 3. 메인 화면: SignupScreen
// ----------------------------------------------------------------             
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // 컨트롤러 및 포커스 노드 설정
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _nickController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _pwFocusNode = FocusNode();
  final FocusNode _nickFocusNode = FocusNode();

  // 회원가입 로직 상태 변수
  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  String? _emailError;
  double _currentWaveHeight = 0.35;

  @override
  void initState() {
    super.initState();
    // 입력창 포커스에 따른 배경 높이 조절 리스너
    _emailFocusNode.addListener(_onFocusChange);
    _pwFocusNode.addListener(_onFocusChange);
    _nickFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      // 키보드 입력 시 파도를 위로 끌어올림
      _currentWaveHeight = (_emailFocusNode.hasFocus || _pwFocusNode.hasFocus || _nickFocusNode.hasFocus) ? 0.65 : 0.35;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _pwController.dispose();
    _nickController.dispose();
    _emailFocusNode.dispose();
    _pwFocusNode.dispose();
    _nickFocusNode.dispose();
    super.dispose();
  }

  // 이메일 및 비밀번호 정규식 검사
  bool _checkEmailFormat(String email) => RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email);
  bool _checkPasswordFormat(String password) => RegExp(r'^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$').hasMatch(password);

  // 회원가입 처리 로직
  Future<void> _handleSignUp() async {
    if (!_isEmailValid || !_isPasswordValid || _nickController.text.length < 2) {
      VipaSnackBar.show(context, '입력 형식을 다시 확인해주세요.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final success = await AuthController.signUp(
        email: _emailController.text.trim(),
        password: _pwController.text.trim(),
        nickname: _nickController.text.trim(),
      );

      if (!mounted) return;
      if (success) {
        VipaSnackBar.show(context, '회원가입 성공! 로그인해주세요.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        setState(() => _emailError = '이미 사용 중인 이메일이거나 서버 에러입니다.');
        VipaSnackBar.show(context, '가입 정보를 확인해주세요.', isError: true);
      }
    } catch (e) {
      if (mounted) VipaSnackBar.show(context, '서버 연결에 실패했습니다.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E4AD),
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // [배경] 파도 레이어
          Positioned.fill(
            child: WaveBackground(waveColor: Colors.white, waveHeightFactor: _currentWaveHeight),
          ),
          // [전면] 입력 폼 레이어
          SafeArea(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // 1. 타이틀 애니메이션 (0.0초 지연)
                      _FadeSlideTransition(
                        delay: 0.0,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(color: Colors.black87, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // 2. 이메일 입력 섹션 (0.2초 지연)
                      _FadeSlideTransition(
                        delay: 0.2,
                        child: Column(
                          children: [
                            _buildUnderlineTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              hintText: '이메일',
                              icon: RemixIcons.mail_fill,
                              errorText: _emailError,
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (val) {
                                setState(() {
                                  _isEmailValid = _checkEmailFormat(val);
                                  _emailError = null;
                                });
                              },
                              activeColor: _isEmailValid ? Colors.blueAccent : Colors.black87,
                            ),
                            if (_emailController.text.isNotEmpty && !_isEmailValid)
                              _buildValidationText('⚠️ 올바른 이메일 형식이 아닙니다.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 3. 비밀번호 입력 섹션 (0.4초 지연)
                      _FadeSlideTransition(
                        delay: 0.4,
                        child: Column(
                          children: [
                            _buildUnderlineTextField(
                              controller: _pwController,
                              focusNode: _pwFocusNode,
                              hintText: '비밀번호',
                              icon: RemixIcons.lock_password_fill,
                              isObscure: true,
                              onChanged: (val) => setState(() => _isPasswordValid = _checkPasswordFormat(val)),
                              activeColor: _isPasswordValid ? Colors.green : Colors.black87,
                            ),
                            if (_pwController.text.isNotEmpty && !_isPasswordValid)
                              _buildValidationText('⚠️ 소문자, 숫자, 특수문자 포함 8자 이상'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // 4. 닉네임 입력 섹션 (0.6초 지연)
                      _FadeSlideTransition(
                        delay: 0.6,
                        child: Column(
                          children: [
                            _buildUnderlineTextField(
                              controller: _nickController,
                              focusNode: _nickFocusNode,
                              hintText: '닉네임 (2자 이상)',
                              icon: RemixIcons.user_3_fill,
                              onChanged: (val) => setState(() {}),
                              activeColor: _nickController.text.length >= 2 ? Colors.blueAccent : Colors.black87,
                            ),
                            if (_nickController.text.isNotEmpty && _nickController.text.length < 2)
                              _buildValidationText('⚠️ 닉네임은 2자 이상 입력해주세요.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),

                      // 5. 완료 버튼 애니메이션 (0.8초 지연)
                      _FadeSlideTransition(
                        delay: 0.8,
                        child: _buildPrimaryButton(
                          text: _isLoading ? '처리 중...' : '회원가입 완료',
                          onPressed: (_isEmailValid && _isPasswordValid && _nickController.text.length >= 2 && !_isLoading) ? _handleSignUp : () {},
                          color: (_isEmailValid && _isPasswordValid && _nickController.text.length >= 2) ? Colors.black87 : Colors.black26,
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 6. 하단 링크 (1.0초 지연)
                      _FadeSlideTransition(
                        delay: 1.0,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('이미 계정이 있으신가요? 로그인', style: TextStyle(color: Colors.black54, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI 컴포넌트 헬퍼 함수 ---

  Widget _buildValidationText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(color: Colors.redAccent, fontSize: 11)),
      ),
    );
  }

  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
    Color activeColor = Colors.black87,
    String? errorText,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: isObscure,
        onChanged: onChanged,
        keyboardType: keyboardType,
        cursorColor: Colors.black87,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: activeColor),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          errorText: errorText,
          errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 1)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: activeColor, width: 2)),
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
      width: double.infinity,
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
}