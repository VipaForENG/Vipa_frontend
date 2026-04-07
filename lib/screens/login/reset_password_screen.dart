// screens/login/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import 'package:vipa/api/api_service.dart';
import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';
import 'package:dio/dio.dart';
// 아래 파일은 기존 프로젝트에서 쓰던 다이얼로그 위젯입니다. 경로를 확인해주세요.
// import '../../Message_widget/passwordfind_message.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _inputController =
      TextEditingController(); // 다이얼로그용
  bool _isLoading = false;

  /// [함수] 인증 코드 발송 처리
  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      VipaSnackBar.show(context, '이메일을 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);
    bool success = await AuthController.sendRecoveryCode(email);
    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      VipaSnackBar.show(context, '인증 코드가 발송되었습니다.');
      _showAuthDialog(); // 성공 시에만 팝업 띄움
    } else {
      if (!mounted) return;
      VipaSnackBar.show(context, '존재하지 않는 이메일이거나 발송에 실패했습니다.');
    }
  }

  /// [함수] 코드 검증 및 다음 단계 이동
  Future<void> _handleVerifyCode() async {
    final email = _emailController.text.trim();
    final code = _inputController.text.trim();

    if (code.length < 6) {
      VipaSnackBar.show(context, '6자리 코드를 입력해주세요.');
      return;
    }

    bool isVerified = await AuthController.verifyRecoveryCode(email, code);

    if (isVerified) {
      if (!mounted) return;
      Navigator.pop(context); // 다이얼로그 닫기

      // 다음 화면으로 이메일과 코드를 넘겨주어야 최종 변경 가능
      Navigator.pushNamed(
        context,
        AppRoutes.changePassword,
        arguments: {'email': email, 'code': code},
      );
    } else {
      if (!mounted) return;
      VipaSnackBar.show(context, '인증번호가 틀렸거나 만료되었습니다.');
    }
  }

  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // 외부 클릭으로 닫기 방지
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          '인증번호 입력',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: _inputController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: '인증번호 6자리',
            counterText: "", // 글자수 제한 표시 제거
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: _handleVerifyCode, // 검증 함수 실행
            child: const Text(
              '인증확인',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '비밀번호 찾기',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
              const Icon(
                RemixIcons.lock_password_line,
                size: 80,
                color: Colors.black87,
              ),
              const SizedBox(height: 30),
              const Text(
                '가입 시 사용한 이메일을 입력해주세요.\n인증번호를 보내드립니다.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
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
                  onPressed: _isLoading ? null : _handleSendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '인증요청',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
