// screens/login/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../routes/app_routes.dart';
// 아래 파일은 기존 프로젝트에서 쓰던 다이얼로그 위젯입니다. 경로를 확인해주세요.
// import '../../Message_widget/passwordfind_message.dart'; 

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _inputController = TextEditingController(); // 다이얼로그용

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('비밀번호 찾기', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(RemixIcons.arrow_left_line, color: Colors.black),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(RemixIcons.lock_password_line, size: 80, color: Colors.black87),
              const SizedBox(height: 30),
              const Text(
                '가입 시 사용한 이메일을 입력해주세요.\n인증번호를 보내드립니다.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
              ),
              const SizedBox(height: 50),

              // 로그인 화면과 통일된 언더라인 입력창
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(RemixIcons.mail_fill, size: 20),
                    prefixIconConstraints: BoxConstraints(minWidth: 35),
                    hintText: '이메일 주소',
                    hintStyle: TextStyle(color: Colors.black38),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black12, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black87, width: 2),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 인증요청 버튼
              SizedBox(
                width: 300,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 실제 이메일 발송 API 연동
                    // 다른 프로젝트의 다이얼로그 로직 통합
                    _showAuthDialog();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '인증요청',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAuthDialog() {
    // 만약 CustomDialog.showInputDialog가 준비되어 있다면 사용하시고, 
    // 여기서는 기본 AlertDialog 예시로 대체합니다.
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('인증번호 입력'),
        content: TextField(
          controller: _inputController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: '인증번호 6자리를 입력하세요'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pushNamed(context, AppRoutes.changePassword); // 새 비번 설정 페이지로
            },
            child: const Text('인증확인'),
          ),
        ],
      ),
    );
  }
}