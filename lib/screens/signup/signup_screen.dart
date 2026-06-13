import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();

  bool _isLoading = false;
  bool _isEmailValid = false;
  bool _isPasswordValid = false;

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
    final error = await AuthController.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      nickname: _nicknameController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      VipaSnackBar.show(context, '회원가입이 완료되었습니다. 로그인해주세요.');
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    } else {
      VipaSnackBar.show(context, error, isError: true);
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                        const SizedBox(height: 68),
                        const VipaMark(size: 72),
                        const SizedBox(height: 22),
                        const Text(
                          '회원가입',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 42,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.4,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'VIPA에 가입해 새로운 경험을 즐겨보세요!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 56),
                        _SignupField(
                          label: '이메일',
                          hint: '이메일',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) => setState(
                            () => _isEmailValid = _checkEmailFormat(value),
                          ),
                        ),
                        const SizedBox(height: 13),
                        _SignupField(
                          label: '비밀번호',
                          hint: '비밀번호',
                          controller: _passwordController,
                          obscureText: true,
                          onChanged: (value) => setState(
                            () => _isPasswordValid = _checkPasswordFormat(value),
                          ),
                        ),
                        const SizedBox(height: 13),
                        _SignupField(
                          label: '닉네임',
                          hint: '닉네임',
                          controller: _nicknameController,
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 27),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: AuthColors.primary,
                              disabledBackgroundColor: AuthColors.primary
                                  .withValues(alpha: 0.65),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              _isLoading ? '처리 중...' : 'VIPA 시작하기!',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 39),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Text.rich(
                            TextSpan(
                              text: '이미 계정이 있으신가요? ',
                              children: [
                                TextSpan(
                                  text: '로그인',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 42),
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
}

class _SignupField extends StatelessWidget {
  const _SignupField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool obscureText;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 9),
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            obscureText: obscureText,
            keyboardType: keyboardType,
            cursorColor: AuthColors.primary,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: hint,
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
                borderSide: const BorderSide(color: Color(0xFF2196F3)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
