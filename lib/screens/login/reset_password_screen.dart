import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import 'auth_widgets.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.initialEmail,
    this.isFromMyPage = false,
  });

  final String? initialEmail;
  final bool isFromMyPage;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    // 마이페이지에서 진입하면 저장된 이메일을 미리 채워 사용자의 입력 부담을 줄인다.
    _emailController.text = widget.initialEmail ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (!_isEmailValid(email)) {
      setState(() => _emailError = '존재하는 이메일이 아닙니다.');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });
    final success = await AuthController.sendRecoveryCode(email);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      VipaSnackBar.show(context, '인증 코드가 발송되었습니다.');
      // 인증번호 화면에서도 마이페이지 진입 여부를 유지해 완료 후 복귀 위치를 구분한다.
      Navigator.pushNamed(
        context,
        AppRoutes.verificationCode,
        arguments: <String, dynamic>{
          'email': email,
          'isFromMyPage': widget.isFromMyPage,
        },
      );
      return;
    }

    setState(() => _emailError = '존재하는 이메일이 아닙니다.');
    VipaSnackBar.show(context, '이메일을 확인해주세요.', isError: true);
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 121),
          Text(
            widget.isFromMyPage ? '비밀번호 변경 해주세요!' : '혹시 비밀번호를 잊으셨나요?!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            widget.isFromMyPage
                ? '이메일을 확인하고 인증번호를 받아주세요!'
                : '이메일을 입력하고 인증번호를 받아보세요!',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 91),
          AuthTextField(
            controller: _emailController,
            label: '이메일',
            hintText: '이메일',
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: (_) => setState(() => _emailError = null),
          ),
          const SizedBox(height: 27),
          AuthButton(
            text: _isLoading
                ? '전송 중...'
                : (widget.isFromMyPage ? '인증번호 입력' : '인증번호 받기'),
            onPressed: _isLoading ? null : _handleSendCode,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
