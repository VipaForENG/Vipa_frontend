import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../Design/snack_bar.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // [컨트롤러] 사용자 입력값 제어
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _nickController = TextEditingController();

  // [상태 관리 변수] 실시간 검사 및 UI 피드백용
  bool _isLoading = false;         // 서버 통신 중 상태
  bool _isEmailValid = false;      // 이메일 형식 통과 여부
  bool _isPasswordValid = false;   // 비밀번호 보안 규칙 통과 여부
  String? _emailError;             // 서버로부터 받은 중복 에러 메시지

  /// [함수] _checkEmailFormat: 이메일 정규식 검사 (@와 도메인 포함 여부)
  bool _checkEmailFormat(String email) {
    return RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
  }

  /// [함수] _checkPasswordFormat: 비밀번호 정규식 검사 (소문자, 숫자, 특수문자 포함 8자 이상)
  bool _checkPasswordFormat(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$')
        .hasMatch(password);
  }

  /// [함수] _handleSignUp: 최종 회원가입 버튼 클릭 시 실행되는 로직
  /// [함수] _handleSignUp: 최종 회원가입 버튼 클릭 시 실행되는 로직
  Future<void> _handleSignUp() async {
    // 닉네임 2자 이상 조건도 포함하여 최종 확인
    if (!_isEmailValid || !_isPasswordValid || _nickController.text.length < 2) {
      VipaSnackBar.show(context, '입력 형식을 다시 확인해주세요.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 2. AuthController 호출 시 백엔드 스키마와 일치하는지 확인
      final success = await AuthController.signUp(
        email: _emailController.text.trim(),
        password: _pwController.text.trim(),
        nickname: _nickController.text.trim(),
        // 만약 AuthController에서 처리 안 한다면 여기서 파라미터를 추가해야 함
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
      // 타임아웃이나 서버 다운 시 catch로 들어옴
      if (mounted) VipaSnackBar.show(context, '서버 연결에 실패했습니다.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                const SizedBox(height: 40),
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
                const SizedBox(height: 60),

                // [이메일 필드] 입력 시 실시간으로 형식을 검사함
                _buildUnderlineTextField(
                  controller: _emailController,
                  hintText: '이메일',
                  icon: RemixIcons.mail_fill,
                  errorText: _emailError, 
                  onChanged: (val) {
                    setState(() {
                      _isEmailValid = _checkEmailFormat(val);
                      _emailError = null; 
                    });
                  },
                  activeColor: _isEmailValid ? Colors.blueAccent : Colors.black87,
                ),
                // [추가] 이메일 형식 미달 시 실시간 가이드
                if (_emailController.text.isNotEmpty && !_isEmailValid)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(' ⚠️ 올바른 이메일 형식이 아닙니다. (@, 도메인 포함)', 
                        style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                    ),
                  ),
                const SizedBox(height: 25),

                // 2. 비밀번호 필드 영역 (기존과 동일)
                _buildUnderlineTextField(
                  controller: _pwController,
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
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(' ⚠️ 소문자, 숫자, 특수문자 포함 8자 이상 필수', 
                        style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                    ),
                  ),
                const SizedBox(height: 25),

                // 3. 닉네임 필드 영역 (글자 수 제한 등 추가 가능)
                _buildUnderlineTextField(
                  controller: _nickController,
                  hintText: '닉네임 (2자 이상)',
                  icon: RemixIcons.user_3_fill,
                  onChanged: (val) {
                    setState(() {
                      // 닉네임은 간단하게 2자 이상인지 실시간 검사
                    });
                  },
                  activeColor: _nickController.text.length >= 2 ? Colors.blueAccent : Colors.black87,
                ),
                // [추가] 닉네임 실시간 가이드
                if (_nickController.text.isNotEmpty && _nickController.text.length < 2)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(' ⚠️ 닉네임은 2자 이상 입력해주세요.', 
                        style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                    ),
                  ),
                const SizedBox(height: 60),

                // [회원가입 버튼] 유효성 검사 통과 여부에 따라 시각적 피드백 제공
                _buildPrimaryButton(
                  text: _isLoading ? '처리 중...' : '회원가입 완료',
                  // 모든 조건이 충족되어야 버튼 작동
                  onPressed: (_isEmailValid && _isPasswordValid && _nickController.text.length >= 2 && !_isLoading) 
                  ? _handleSignUp 
                  : () {},
                  // 조건 미충족 시 회색으로 표시
                  color: (_isEmailValid && _isPasswordValid && _nickController.text.length >= 2) ? Colors.black87 : Colors.black26,
                  textColor: Colors.white,
                ),
                
                const SizedBox(height: 20),
                
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('이미 계정이 있으신가요? 로그인', 
                    style: TextStyle(color: Colors.black54, fontSize: 13)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI 디자인 위젯 (LoginScreen 스타일 계승) ---

  /// [위젯] _buildUnderlineTextField: 하단 라인 스타일의 입력 필드
  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
    Function(String)? onChanged,
    Color activeColor = Colors.black87,
    String? errorText,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: activeColor),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          errorText: errorText, // 서버 중복 에러 등을 텍스트 필드 바로 아래 표시
          errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12, width: 1),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: activeColor, width: 2),
          ),
          errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 1),
          ),
          focusedErrorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }

  /// [위젯] _buildPrimaryButton: 둥근 모서리의 메인 액션 버튼
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