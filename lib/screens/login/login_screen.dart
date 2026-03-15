import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart'; // RemixIcon 패키지 확인 필요
import '../../routes/app_routes.dart'; // 현재 프로젝트 라우트
import '../../Design/snack_bar.dart'; // 기존 프로젝트의 스낵바 디자인

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  /// [함수] _handleLogin
  void _handleLogin() {
    // 스낵바 피드백 (기존 디자인 적용)
    VipaSnackBar.show(context, '성공적으로 로그인되었습니다!');
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFFFFF),
      // 키보드가 올라올 때 화면이 가려지지 않도록 설정
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 100),
                // 로고 섹션
                const Text(
                  'VIPA',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 45,
                    fontWeight: FontWeight.w900, // 기존 1000 대신 w900 사용
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 60),

                // 이메일 입력 필드
                _buildUnderlineTextField(
                  controller: _idController,
                  hintText: '이메일',
                  icon: RemixIcons.mail_fill,
                ),
                const SizedBox(height: 20),

                // 비밀번호 입력 필드
                _buildUnderlineTextField(
                  controller: _pwController,
                  hintText: '비밀번호',
                  icon: RemixIcons.lock_password_fill,
                  isObscure: true,
                ),
                const SizedBox(height: 40),

                // 로그인 버튼
                _buildPrimaryButton(
                  text: '로그인',
                  onPressed: _handleLogin,
                  color: Colors.black87,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 30),

                // 구글 로그인
                _buildPrimaryButton(
                  text: '구글로 로그인',
                  onPressed: _handleLogin, // 현재는 개발용이라 같은 함수 연결
                  color: Colors.white,
                  textColor: Colors.black87,
                  hasBorder: true,
                ),
                const SizedBox(height: 10),

                // 카카오 로그인
                _buildPrimaryButton(
                  text: '카카오로 로그인',
                  onPressed: _handleLogin,
                  color: const Color(0xFFFEE500),
                  textColor: Colors.black87,
                ),

                const SizedBox(height: 20),

                // 하단 보조 버튼 (회원가입, 비밀번호 찾기)
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

  // --- 위젯 분리 ---

  // 다른 프로젝트 스타일의 언더라인 텍스트 필드
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

  // 버튼 공통 위젯
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
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
        ),
      ),
    );
  }
}