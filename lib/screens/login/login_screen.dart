import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../routes/app_routes.dart';
import '../../Design/snack_bar.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  
  // 버튼별 로딩 상태 관리
  bool _isNormalLoading = false;
  bool _isGoogleLoading = false;
  bool _isKakaoLoading = false;

  /// 일반 이메일 로그인
  Future<void> _handleLogin() async {
    final email = _idController.text.trim();
    final password = _pwController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      VipaSnackBar.show(context, '이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    setState(() => _isNormalLoading = true);
    final result = await AuthController.login(email: email, password: password);
    setState(() => _isNormalLoading = false);

    _processLoginResult(result);
  }

  /// 구글 로그인
  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    final result = await AuthController.loginWithGoogle();
    setState(() => _isGoogleLoading = false);

    _processLoginResult(result, isSocial: true);
  }

  /// 카카오 로그인
  Future<void> _handleKakaoLogin() async {
    setState(() => _isKakaoLoading = true);
    final result = await AuthController.loginWithKakao();
    setState(() => _isKakaoLoading = false);

    _processLoginResult(result, isSocial: true);
  }

  /// 로그인 결과 처리 공통 로직
  void _processLoginResult(Map<String, dynamic>? result, {bool isSocial = false}) {
    if (!mounted) return;

    if (result != null) {
      // TODO: 토큰 저장 로직 (FlutterSecureStorage 등)
      // String token = result['access_token'];
      
      VipaSnackBar.show(context, '성공적으로 로그인되었습니다!');
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // 소셜 로그인은 사용자가 취소해서 null이 반환될 수도 있으므로 에러 메시지를 다르게 처리할 수 있습니다.
      String errorMsg = isSocial ? '소셜 로그인에 실패했거나 취소되었습니다.' : '이메일 또는 비밀번호가 일치하지 않습니다.';
      VipaSnackBar.show(context, errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 혹시라도 셋 중 하나라도 로딩 중이면 전체 버튼 비활성화를 위해 사용
    final bool isAnyLoading = _isNormalLoading || _isGoogleLoading || _isKakaoLoading;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 228, 173),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 95),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    'https://cdn.discordapp.com/attachments/1482731178753654865/1491120727976443994/LOGO-Photoroom.png?ex=69d689e5&is=69d53865&hm=0e97e775c1ae8a46e987be819ef1f600daecbc86c9e51ce0073a328f141e72bf&',
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 100, height: 100,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100, height: 100,
                      color: const Color(0xFFEDF0F3),
                      child: const Icon(Icons.broken_image, color: Colors.black26),
                    ),
                  ),
                ),

                const Text(
                  'VIPA',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 216, 154),
                    fontSize: 45,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 60),

                _buildUnderlineTextField(
                  controller: _idController,
                  hintText: '이메일',
                  icon: RemixIcons.mail_fill,
                ),
                const SizedBox(height: 20),

                _buildUnderlineTextField(
                  controller: _pwController,
                  hintText: '비밀번호',
                  icon: RemixIcons.lock_password_fill,
                  isObscure: true,
                ),
                const SizedBox(height: 40),

                // 로그인 버튼
                _buildPrimaryButton(
                  text: _isNormalLoading ? '로그인 중...' : '로그인',
                  onPressed: isAnyLoading ? () {} : _handleLogin,
                  color: Colors.black87,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 30),

                // 구글 로그인
                _buildPrimaryButton(
                  text: _isGoogleLoading ? '처리 중...' : '구글로 로그인',
                  onPressed: isAnyLoading ? () {} : _handleGoogleLogin,
                  color: Colors.white,
                  textColor: Colors.black87,
                  hasBorder: true,
                ),
                const SizedBox(height: 10),

                // 카카오 로그인
                _buildPrimaryButton(
                  text: _isKakaoLoading ? '처리 중...' : '카카오로 로그인',
                  onPressed: isAnyLoading ? () {} : _handleKakaoLogin,
                  color: const Color(0xFFFEE500),
                  textColor: Colors.black87,
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.signup),
                      child: const Text('회원가입', style: TextStyle(color: Colors.black54)),
                    ),
                    const Text('|', style: TextStyle(color: Colors.black12)),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRoutes.resetPassword),
                      child: const Text('비밀번호 찾기', style: TextStyle(color: Colors.black54)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // _buildUnderlineTextField 와 _buildPrimaryButton 는 기존과 동일하게 사용
  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 2),
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
            side: hasBorder ? const BorderSide(color: Colors.black87) : BorderSide.none,
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