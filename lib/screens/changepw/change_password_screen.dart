import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../routes/app_routes.dart';
import '../../design/snack_bar.dart';
import '../../controllers/auth_controller.dart'; // [추가] 컨트롤러 임포트

class ChangePasswordScreen extends StatefulWidget {
  final bool isFromMyPage;
  const ChangePasswordScreen({super.key, this.isFromMyPage = false});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();
  bool _isLoading = false; // 로딩 상태 추가

  /// [함수] 비밀번호 변경 로직 호출
  Future<void> _handleResetPassword() async {
    final newPassword = _pwController.text.trim();
    final confirmPassword = _confirmPwController.text.trim();

    // 1. 기본 유효성 검사
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      VipaSnackBar.show(context, "비밀번호를 모두 입력해주세요.");
      return;
    }
    if (newPassword != confirmPassword) {
      VipaSnackBar.show(context, "비밀번호가 일치하지 않습니다.");
      return;
    }

    // 2. 이전 화면에서 전달받은 Arguments 꺼내기 (email, code)
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args == null && !widget.isFromMyPage) {
      VipaSnackBar.show(context, "잘못된 접근입니다.");
      return;
    }

    setState(() => _isLoading = true);

    // 3. AuthController를 통해 서버 PATCH 요청
    // 비밀번호 찾기 프로세스라면 넘겨받은 email, code 사용
    bool success = await AuthController.resetPassword(
      email: args?['email'] ?? "",
      code: args?['code'] ?? "",
      newPassword: newPassword,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (!mounted) return;
      VipaSnackBar.show(context, "비밀번호 변경이 완료되었습니다. 다시 로그인해주세요.");

      if (widget.isFromMyPage) {
        Navigator.pop(context);
      } else {
        // 로그인 화면으로 이동하며 이전 스택 다 비우기
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    } else {
      if (!mounted) return;
      VipaSnackBar.show(context, "비밀번호 변경에 실패했습니다. 코드가 만료되었을 수 있습니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.isFromMyPage ? "비밀번호 수정" : "새 비밀번호 설정",
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const Text(
                "안전한 비밀번호로 변경해 주세요.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 50),
              _buildUnderlineField(
                _pwController,
                "새 비밀번호",
                RemixIcons.lock_password_line,
              ),
              const SizedBox(height: 25),
              _buildUnderlineField(
                _confirmPwController,
                "새 비밀번호 확인",
                RemixIcons.checkbox_circle_line,
              ),
              const SizedBox(height: 50),
              SizedBox(
                width: 300,
                height: 52,
                child: ElevatedButton(
                  // 로딩 중에는 클릭 안 되게 null 처리
                  onPressed: _isLoading ? null : _handleResetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "변경 완료",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Widget _buildUnderlineField(
    TextEditingController controller,
    String hint,
    IconData icon,
  ) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
          hintText: hint,
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 2),
          ),
        ),
      ),
    );
  }
}
