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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

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
      setState(() => _passwordError = '소문자, 숫자, 특수문자 조합을 주세요');
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
    final success = await AuthController.resetPassword(
      email: recoveryArgs?['email'] as String? ?? '',
      code: recoveryArgs?['code'] as String? ?? '',
      newPassword: password,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      VipaSnackBar.show(
        context,
        '비밀번호 변경에 실패했습니다. 코드가 만료되었을 수 있습니다.',
        isError: true,
      );
      return;
    }

    if (widget.isFromMyPage) {
      // 마이페이지에서 시작한 변경은 로그인 화면으로 보내지 않고 기존 마이페이지 흐름으로 복귀한다.
      VipaSnackBar.show(context, '비밀번호 변경이 완료되었습니다.');
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    VipaSnackBar.show(context, '비밀번호 변경이 완료되었습니다. 다시 로그인해주세요.');
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 91),
          const Text(
            '비밀번호 변경 해주세요!',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '새롭게 비밀번호를 작성해주세요!',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 75),
          AuthTextField(
            controller: _passwordController,
            label: '비밀번호 입력',
            hintText: '비밀번호',
            obscureText: true,
            errorText: _passwordError,
            onChanged: (_) => setState(() => _passwordError = null),
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _confirmPasswordController,
            label: '비밀번호 확인',
            hintText: '비밀번호',
            obscureText: true,
            errorText: _confirmPasswordError,
            onChanged: (_) => setState(() => _confirmPasswordError = null),
          ),
          const SizedBox(height: 31),
          AuthButton(
            text: _isLoading ? '변경 중...' : '비밀번호 변경',
            onPressed: _isLoading ? null : _handleResetPassword,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
