import 'package:flutter/material.dart';

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
    // [로직] 실제 서버 연동 전까지 비밀번호 확인 없이 바로 홈으로 pushReplacement
    Navigator.pushReplacementNamed(context, '/');
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

              // [위젯] 로그인 버튼 (클릭 시 _handleLogin 함수 호출)
              SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(onPressed: _handleLogin, child: const Text("로그인"))
              ),

              // [위젯] 계정 찾기 및 회원가입 버튼
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(onPressed: () {}, child: const Text("비밀번호를 잃어버리셨나요?")),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/signup'), child: const Text("회원가입")),
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
  /// 목적: 소셜 로그인 버튼의 디자인을 생성합니다. (매개변수로 로그인 로직 함수를 받음)
  Widget _buildSocialLoginButton(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(backgroundColor: bgColor),
        onPressed: onPressed, // [로직] 클릭 시 바로 로그인 처리
        child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      ),
    );
  }
}