import 'package:flutter/material.dart';
// [임포트] 라우트 상수를 사용하기 위해 추가합니다.
import '../../routes/app_routes.dart';

/// [클래스] LoginScreen
/// 목적: 일반 이메일 로그인과 소셜 로그인 버튼을 제공합니다. (개발용 자동 로그인 기능 포함)
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  /// [함수] _handleLogin
  /// 목적: 개발 편의를 위해 비밀번호 검증 없이 즉시 홈으로 이동합니다.
  void _handleLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text("로그인", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),

              // [위젯] 이메일/비번 입력 필드
              TextField(controller: _idController, decoration: const InputDecoration(labelText: "이메일", border: OutlineInputBorder())),
              const SizedBox(height: 15),
              TextField(controller: _pwController, obscureText: true, decoration: const InputDecoration(labelText: "비밀번호", border: OutlineInputBorder())),
              const SizedBox(height: 20),

              // [위젯] 로그인 버튼
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(onPressed: _handleLogin, child: const Text("로그인"))
              ),

              // [위젯] 계정 찾기 및 회원가입 버튼
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                // [로직 수정] 비밀번호 찾기 화면으로 이동하도록 연결 완료
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.resetPassword), 
                  child: const Text("비밀번호를 잃어버리셨나요?")
                ),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.signup), 
                  child: const Text("회원가입")
                ),
              ]),

              const Divider(height: 40),

              // [위젯] 소셜 로그인 영역
              const Text("소셜 로그인으로 시작하기"),
              const SizedBox(height: 20),
              _buildSocialLoginButton("Google로 시작하기", Colors.white, Colors.black87, _handleLogin),
              const SizedBox(height: 10),
              _buildSocialLoginButton("Kakao로 시작하기", const Color(0xFFFEE500), Colors.black87, _handleLogin),
            ],
          ),
        ),
      ),
    );
  }

  /// [함수] _buildSocialLoginButton
  Widget _buildSocialLoginButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(backgroundColor: bgColor),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}