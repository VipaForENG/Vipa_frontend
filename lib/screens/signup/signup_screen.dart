import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'dart:math' as math;
import '../../routes/app_routes.dart';
import '../../Design/snack_bar.dart';
import '../../controllers/auth_controller.dart';
import '../../services/auth_service.dart';

// --- 로그인 화면과 동일한 파도 배경 위젯 ---

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

  const _LoopingWave({super.key, required this.waveColor, required this.heightFactor});

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
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height + 1000);
    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.white.withOpacity(0.9),
        const Color(0xFFFDF5E6),
        const Color(0xFFF5E4AD), // 로그인 화면과 동일한 하단 색상
      ],
      stops: const [0.0, 0.4, 1.0],
    );

    Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;

    Path path = Path();
    double baseHeight = size.height * (1.0 - heightFactor); 
    double waveAmplitude = 18.0;

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

// --- 회원가입 화면 메인 ---

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _nickController = TextEditingController();

  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _pwFocusNode = FocusNode();
  final FocusNode _nickFocusNode = FocusNode();

  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  String? _emailError;

  // 파도 높이 상태 (로그인 화면과 동일한 로직)
  double _currentWaveHeight = 0.35;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _pwFocusNode.addListener(_onFocusChange);
    _nickFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      if (_emailFocusNode.hasFocus || _pwFocusNode.hasFocus || _nickFocusNode.hasFocus) {
        _currentWaveHeight = 0.65;
      } else {
        _currentWaveHeight = 0.35;
      }
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

  bool _checkEmailFormat(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  bool _checkPasswordFormat(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$')
        .hasMatch(password);
  }

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
        setState(() {
          _emailError = '이미 사용 중인 이메일이거나 서버 에러입니다.';
        });
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
      backgroundColor: const Color.fromARGB(255, 245, 228, 173), // 로그인과 동일한 노란 배경
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 투명하게 설정하여 파도가 보이게 함
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true, // 파도가 AppBar 영역까지 차도록 설정
      body: Stack(
        children: [
          // 배경 파도
          Positioned.fill(
            child: WaveBackground(
              waveColor: Colors.white,
              waveHeightFactor: _currentWaveHeight,
            ),
          ),
          
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
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),

                      // 이메일 필드
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
                      const SizedBox(height: 25),

                      // 비밀번호 필드
                      _buildUnderlineTextField(
                        controller: _pwController,
                        focusNode: _pwFocusNode,
                        hintText: '비밀번호',
                        icon: RemixIcons.lock_password_fill,
                        isObscure: true,
                        onChanged: (val) {
                          setState(() {
                            _isPasswordValid = _checkPasswordFormat(val);
                          });
                        },
                        activeColor: _isPasswordValid ? Colors.green : Colors.black87,
                      ),
                      if (_pwController.text.isNotEmpty && !_isPasswordValid)
                        _buildValidationText('⚠️ 소문자, 숫자, 특수문자 포함 8자 이상'),
                      const SizedBox(height: 25),

                      // 닉네임 필드
                      _buildUnderlineTextField(
                        controller: _nickController,
                        focusNode: _nickFocusNode,
                        hintText: '닉네임 (2자 이상)',
                        icon: RemixIcons.user_3_fill,
                        onChanged: (val) {
                          setState(() {});
                        },
                        activeColor: _nickController.text.length >= 2 ? Colors.blueAccent : Colors.black87,
                      ),
                      if (_nickController.text.isNotEmpty && _nickController.text.length < 2)
                        _buildValidationText('⚠️ 닉네임은 2자 이상 입력해주세요.'),
                      
                      const SizedBox(height: 60),

                      // 회원가입 버튼
                      _buildPrimaryButton(
                        text: _isLoading ? '처리 중...' : '회원가입 완료',
                        onPressed: (_isEmailValid && _isPasswordValid && _nickController.text.length >= 2 && !_isLoading) 
                            ? _handleSignUp 
                            : () {},
                        color: (_isEmailValid && _isPasswordValid && _nickController.text.length >= 2) ? Colors.black87 : Colors.black26,
                        textColor: Colors.white,
                      ),
                      
                      const SizedBox(height: 20),
                      
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('이미 계정이 있으신가요? 로그인', 
                          style: TextStyle(color: Colors.black54, fontSize: 13)),
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

  // --- UI 컴포넌트 (디자인 통일) ---

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
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: activeColor, width: 2),
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
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}