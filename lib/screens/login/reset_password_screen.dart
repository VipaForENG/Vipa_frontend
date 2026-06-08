import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../design/animation_design.dart';
import '../../design/app_colors.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';

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
  final TextEditingController _codeController = TextEditingController(); // 인증번호 입력용

  bool _isLoading = false;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // --- 비즈니스 로직 ---

  bool _isEmailValid(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _handleSendCode() async {
    final email = _emailController.text.trim();
    if (!_isEmailValid(email)) {
      setState(() => _emailError = '올바른 이메일 형식이 아닙니다.');
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
      _showAuthDialog(email);
    } else {
      VipaSnackBar.show(context, '이메일 발송에 실패했습니다. 다시 시도해주세요.', isError: true);
    }
  }

  Future<void> _handleVerifyCode(String email) async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      VipaSnackBar.show(context, '6자리 인증번호를 입력해주세요.', isError: true);
      return;
    }

    bool isVerified = await AuthController.verifyRecoveryCode(email, code);

    if (!mounted) return;

    if (isVerified) {
      final navigator = Navigator.of(context);
      navigator.pop(); // 다이얼로그 닫기
      navigator.pushNamed(
        AppRoutes.changePassword,
        arguments: <String, dynamic>{'email': email, 'code': code},
      );
    } else {
      VipaSnackBar.show(context, '인증번호가 틀렸거나 만료되었습니다.', isError: true);
    }
  }

  // --- UI 컴포넌트 ---

  void _showAuthDialog(String email) {
    _codeController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text(
          '인증번호 입력',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
        content: TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: '인증번호 6자리',
            hintStyle: TextStyle(color: Color(0xFFffa370)),
            counterText: "",
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Color(0xFFffa370))),
          ),
          TextButton(
            onPressed: () => _handleVerifyCode(email),
            child: const Text('인증확인', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  const SizedBox(height: 121),
                  FadeSlideTransition(
                    delay: 0.0,
                    child: Text(
                      widget.isFromMyPage ? '비밀번호를 변경하세요!' : '혹시 비밀번호를 잊으셨나요?!',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeSlideTransition(
                    delay: 0.1,
                    child: Text(
                      widget.isFromMyPage
                          ? '이메일을 확인하고 인증번호를 받아주세요!'
                          : '이메일을 입력하고 인증번호를 받아보세요!',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 91),
                  FadeSlideTransition(
                    delay: 0.2,
                    child: _buildEmailTextField(),
                  ),
                  const SizedBox(height: 27),
                  FadeSlideTransition(
                    delay: 0.3,
                    child: _buildPrimaryButton(
                      text: _isLoading ? '전송 중...' : (widget.isFromMyPage ? '인증번호 입력' : '인증번호 받기'),
                      onPressed: _isLoading ? () {} : _handleSendCode,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailTextField() {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        cursorColor: AppColors.accent,
        onChanged: (_) => setState(() => _emailError = null),
        decoration: InputDecoration(
          labelText: '이메일',
          labelStyle: const TextStyle(color: AppColors.accent),
          errorText: _emailError,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.accent, width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: 300,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}