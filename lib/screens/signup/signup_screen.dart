import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../routes/app_routes.dart';
import '../../Design/snack_bar.dart';
import '../../controllers/auth_controller.dart';
// 🔥 공용 애니메이션 모듈 임포트
import '../../design/animation_design.dart';
import '../../design/app_colors.dart';

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

  // 🔥 파도 높이: 가독성을 위해 키보드 올라올 때 0.45로 조정 (가림 방지)
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
      _currentWaveHeight =
          (_emailFocusNode.hasFocus ||
              _pwFocusNode.hasFocus ||
              _nickFocusNode.hasFocus)
          ? 0.45 // ⬅️ 0.65는 너무 높아서 입력창을 가리므로 0.45가 적당합니다.
          : 0.35;
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

  bool _checkEmailFormat(String email) => RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  ).hasMatch(email);
  bool _checkPasswordFormat(String password) => RegExp(
    r'^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
  ).hasMatch(password);

  Future<void> _handleSignUp() async {
    if (!_isEmailValid ||
        !_isPasswordValid ||
        _nickController.text.length < 2) {
      VipaSnackBar.show(context, '입력 형식을 다시 확인해주세요.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final String? errorDetail = await AuthController.signUp(
        email: _emailController.text.trim(),
        password: _pwController.text.trim(),
        nickname: _nickController.text.trim(),
      );

      if (!mounted) return;

      if (errorDetail == null) {
        VipaSnackBar.show(context, '회원가입 성공! 로그인해주세요.');
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      } else {
        VipaSnackBar.show(context, errorDetail, isError: true);

        setState(() {
          if (errorDetail.contains('이메일')) _emailError = errorDetail;
        });
      }
    } catch (e) {
      if (mounted) VipaSnackBar.show(context, '서버 연결에 실패했습니다.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 로그인 페이지와 통일한 색상 세팅
    const Color bgColor = AppColors.background;
    const Color waveColor = AppColors.wave;

    return Scaffold(
      // ✅ 1. 하단 단차 해결: Scaffold 배경을 파도 색으로 미리 칠해둡니다.
      backgroundColor: waveColor,
      resizeToAvoidBottomInset: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // ✅ 2. 상단 배경색을 먼저 꽉 채웁니다.
          Container(color: bgColor),

          // ✅ 3. 그 위에 파도를 그립니다. 파도 아래는 Scaffold 배경색 덕분에 단차가 생기지 않습니다.
          Positioned.fill(
            child: WaveBackground(
              waveColor: waveColor,
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
                      FadeSlideTransition(
                        delay: 0.0,
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'SIGN UP',
                            style: TextStyle(
                              color: Color(0xFFf75f0b),
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      FadeSlideTransition(
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
                              activeColor: _isEmailValid
                                  ? Color(0xFFf75f0b)
                                  : Color(0xFFffa370),
                            ),
                            if (_emailController.text.isNotEmpty &&
                                !_isEmailValid)
                              _buildValidationText('⚠️ 올바른 이메일 형식이 아닙니다.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      FadeSlideTransition(
                        delay: 0.4,
                        child: Column(
                          children: [
                            _buildUnderlineTextField(
                              controller: _pwController,
                              focusNode: _pwFocusNode,
                              hintText: '비밀번호',
                              icon: RemixIcons.lock_password_fill,
                              isObscure: true,
                              onChanged: (val) => setState(
                                () => _isPasswordValid = _checkPasswordFormat(
                                  val,
                                ),
                              ),
                              activeColor: _isPasswordValid
                                  ? Color(0xFFf75f0b)
                                  : Color(0xFFffa370),
                            ),
                            if (_pwController.text.isNotEmpty &&
                                !_isPasswordValid)
                              _buildValidationText('⚠️ 소문자, 숫자, 특수문자 포함 8자 이상'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      FadeSlideTransition(
                        delay: 0.6,
                        child: Column(
                          children: [
                            _buildUnderlineTextField(
                              controller: _nickController,
                              focusNode: _nickFocusNode,
                              hintText: '닉네임 (2자 이상)',
                              icon: RemixIcons.user_3_fill,
                              onChanged: (val) => setState(() {}),
                              activeColor: _nickController.text.length >= 2
                                  ? Color(0xFFf75f0b)
                                  : Color(0xFFffa370),
                            ),
                            if (_nickController.text.isNotEmpty &&
                                _nickController.text.length < 2)
                              _buildValidationText('⚠️ 닉네임은 2자 이상 입력해주세요.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 60),
                      FadeSlideTransition(
                        delay: 0.8,
                        child: _buildPrimaryButton(
                          text: _isLoading ? '처리 중...' : '회원가입 완료',
                          onPressed:
                              (_isEmailValid &&
                                  _isPasswordValid &&
                                  _nickController.text.length >= 2 &&
                                  !_isLoading)
                              ? _handleSignUp
                              : () {},
                          color:
                              (_isEmailValid &&
                                  _isPasswordValid &&
                                  _nickController.text.length >= 2)
                              ? Color(0xFFf75f0b)
                              : Color(0xFFffa370),
                          textColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeSlideTransition(
                        delay: 1.0,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            '이미 계정이 있으신가요? 로그인',
                            style: TextStyle(
                              color: Color(0xfff75f0b),
                              fontSize: 13,
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
          ),
        ],
      ),
    );
  }

  // --- UI 컴포넌트 헬퍼 ---

  Widget _buildValidationText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(color: Colors.redAccent, fontSize: 11),
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
