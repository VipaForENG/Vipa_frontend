import 'package:flutter/material.dart';

/// [클래스] ChangePasswordScreen
/// 목적: 새 비밀번호를 입력하고 변경하는 UI (비밀번호 찾기/마이페이지 공용)
class ChangePasswordScreen extends StatefulWidget {
  final bool isFromMyPage;

  const ChangePasswordScreen({super.key, this.isFromMyPage = false});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isFromMyPage ? "비밀번호 수정" : "새 비밀번호 설정", 
             style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("안전한 비밀번호로 변경해 주세요.", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 32),

            // 새 비밀번호 입력
            TextField(
              controller: _pwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "새 비밀번호",
                helperText: "8자 이상, 숫자와 영문자를 포함해 주세요.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            // 비밀번호 확인 입력
            TextField(
              controller: _confirmPwController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "새 비밀번호 확인",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 40),

            // 변경 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  // 성공 메시지 후 화면 이동
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("비밀번호 변경이 완료되었습니다.")),
                  );
                  
                  if (widget.isFromMyPage) {
                    Navigator.pop(context); // 마이페이지로 복귀
                  } else {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // 로그인으로 이동
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text("변경 완료", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}