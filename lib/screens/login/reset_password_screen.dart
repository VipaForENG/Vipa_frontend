import 'package:flutter/material.dart';

/// [클래스] ResetPasswordScreen
/// 목적: 비밀번호 재설정을 위한 이메일 입력 및 인증번호 확인 UI
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _isCodeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("비밀번호 찾기", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "가입 시 사용한 이메일을 입력해 주세요.\n인증 번호를 보내드립니다.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 32),
            
            // 이메일 입력 필드
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "이메일 주소",
                hintText: "example@vipa.com",
                suffixIcon: TextButton(
                  onPressed: () {
                    // UI 동작 확인용: 인증번호 입력창 활성화
                    setState(() => _isCodeSent = true);
                  },
                  child: Text(_isCodeSent ? "재발송" : "인증요청"),
                ),
                border: const OutlineInputBorder(),
              ),
            ),

            // 인증번호 입력 필드 (인증요청 버튼 클릭 시 노출)
            if (_isCodeSent) ...[
              const SizedBox(height: 16),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "인증번호 6자리",
                  hintText: "000000",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // 인증 완료 후 비밀번호 변경 페이지로 이동
                    Navigator.pushNamed(context, '/change-password');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("인증 확인", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}