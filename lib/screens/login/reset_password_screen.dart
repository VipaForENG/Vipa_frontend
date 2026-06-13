import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../design/app_colors.dart';
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
  final _emailController = TextEditingController();

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
    super.dispose();
  }

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
      Navigator.pushNamed(
        context,
        AppRoutes.verificationCode,
        arguments: <String, dynamic>{
          'email': email,
          'isFromMyPage': widget.isFromMyPage,
        },
      );
    } else {
      setState(() => _emailError = '존재하는 이메일이 아닙니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 330),
                    child: Column(
                      children: [
                        const SizedBox(height: 180),
                        Text(
                          widget.isFromMyPage
                              ? '비밀번호를 변경하세요!'
                              : '헉! 비밀번호를 잊으셨군요!',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.9,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '이메일을 입력하여 인증번호를 받아주세요!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 120),
                        _emailField(),
                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSendCode,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary
                                  .withValues(alpha: 0.65),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _isLoading ? '전송 중...' : '인증번호 받기',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이메일',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 56,
          child: TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            cursorColor: AppColors.primary,
            onChanged: (_) => setState(() => _emailError = null),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: '이메일',
              hintStyle: const TextStyle(
                color: Color(0xFFB9BCC5),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xFFF2F3F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 26,
          child: _emailError == null
              ? null
              : Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _emailError!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
