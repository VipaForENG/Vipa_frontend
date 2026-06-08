import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';
import '../../design/app_colors.dart'; 

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  bool _checkEmailFormat(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  bool _checkPasswordFormat(String password) {
    return RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$').hasMatch(password);
  }

  Future<void> _handleSignUp() async {
    if (!_isEmailValid ||
        !_isPasswordValid ||
        _nicknameController.text.trim().length < 2) {
      VipaSnackBar.show(context, '입력 정보를 다시 확인해주세요.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final errorDetail = await AuthController.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      nickname: _nicknameController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorDetail == null) {
      VipaSnackBar.show(context, '회원가입이 완료되었습니다. 로그인해주세요.');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    VipaSnackBar.show(context, errorDetail, isError: true);
    if (errorDetail.contains('이메일') || errorDetail.toLowerCase().contains('email')) {
      setState(() => _emailError = errorDetail);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _isEmailValid &&
        _isPasswordValid &&
        _nicknameController.text.trim().length >= 2 &&
        !_isLoading;

    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 25),
          const VipaMark(size: 42),
          const SizedBox(height: 8),
          const Text(
            '회원가입',
            style: TextStyle(
              color: Color(0xFF2D3436), // 정의되지 않은 textMain 대신 기존 디자인 색상 적용
              fontSize: 31,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'VIPA와 가장 먼저 새로운 경험을 즐겨보세요!',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 42),
          AuthTextField(
            controller: _emailController,
            label: '이메일',
            hintText: '이메일',
            keyboardType: TextInputType.emailAddress,
            errorText: _emailError,
            onChanged: (value) {
              setState(() {
                _isEmailValid = _checkEmailFormat(value);
                _emailError = null;
              });
            },
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _passwordController,
            label: '비밀번호',
            hintText: '비밀번호',
            obscureText: true,
            onChanged: (value) {
              setState(() => _isPasswordValid = _checkPasswordFormat(value));
            },
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _nicknameController,
            label: '닉네임',
            hintText: '닉네임',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 31),
          AuthButton(
            text: _isLoading ? '처리 중...' : 'VIPA 시작하기!',
            onPressed: canSubmit ? _handleSignUp : null,
          ),
          const SizedBox(height: 29),
          AuthFooterLink(
            prefix: '이미 계정이 있으신가요?',
            action: '로그인',
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}