import 'package:flutter/material.dart';

import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, this.isFromMyPage = false});

  final bool isFromMyPage;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isPasswordValid(String password) {
    return RegExp(
      r'^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
    ).hasMatch(password);
  }

  Future<void> _handleResetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    if (!_isPasswordValid(password)) {
      setState(() => _passwordError = '소문자, 숫자, 특수문자를 조합해 주세요');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _confirmPasswordError = '비밀번호가 일치하지 않습니다.');
      return;
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    final recoveryArgs = args is Map<String, dynamic> ? args : null;
    if (recoveryArgs == null && !widget.isFromMyPage) {
      VipaSnackBar.show(context, '잘못된 접근입니다.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    final success = widget.isFromMyPage
        ? await AuthController.changePassword('', password)
        : await AuthController.resetPassword(
            email: recoveryArgs?['email'] as String? ?? '',
            code: recoveryArgs?['code'] as String? ?? '',
            newPassword: password,
          );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      VipaSnackBar.show(
        context,
        '비밀번호 변경에 실패했습니다. 인증번호가 만료되었을 수 있습니다.',
        isError: true,
      );
      return;
    }
    if (widget.isFromMyPage) {
      Navigator.pop(context);
      return;
    }
    VipaSnackBar.show(context, '비밀번호 변경이 완료되었습니다. 다시 로그인해주세요.');
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
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
                        const Text(
                          '비밀번호 변경해주세요!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.9,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '새롭게 바꿀 비밀번호를 작성해주세요!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 110),
                        _PasswordField(
                          label: '비밀번호 입력',
                          controller: _passwordController,
                          errorText: _passwordError,
                          onChanged: (_) =>
                              setState(() => _passwordError = null),
                        ),
                        const SizedBox(height: 8),
                        _PasswordField(
                          label: '비밀번호 확인',
                          controller: _confirmPasswordController,
                          errorText: _confirmPasswordError,
                          onChanged: (_) =>
                              setState(() => _confirmPasswordError = null),
                        ),
                        const SizedBox(height: 15),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _handleResetPassword,
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
                              _isLoading ? '변경 중...' : '인증번호 입력',
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
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? errorText;

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
        const SizedBox(height: 7),
        SizedBox(
          height: 56,
          child: TextField(
            controller: controller,
            obscureText: true,
            onChanged: onChanged,
            cursorColor: AuthColors.primary,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: '비밀번호',
              hintStyle: const TextStyle(
                color: Color(0xFFB9BCC5),
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
              filled: true,
              fillColor: const Color(0xFFF2F3F6),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AuthColors.primary),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 28,
          child: errorText == null
              ? null
              : Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    errorText!,
                    style: const TextStyle(
                      color: AuthColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
