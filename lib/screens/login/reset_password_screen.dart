import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';

import '../../routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';
// 공용 애니메이션 모듈 임포트
import '../../design/animation_design.dart'; 

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _inputController = TextEditingController(); 
  final FocusNode _emailFocusNode = FocusNode();

  bool _isLoading = false;
  double _currentWaveHeight = 0.35;

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    setState(() {
      _currentWaveHeight = _emailFocusNode.hasFocus ? 0.45 : 0.35;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _inputController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  // --- 비즈니스 로직 ---
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
      _showAuthDialog();
    } else {
      if (!mounted) return;
      VipaSnackBar.show(context, '존재하지 않는 이메일이거나 발송에 실패했습니다.');
    }
  }

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
      Navigator.pop(context); 
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

  // --- UI 컴포넌트 ---
  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('인증번호 입력', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: _inputController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: const InputDecoration(
            hintText: '인증번호 6자리',
            counterText: "", 
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: _handleVerifyCode,
            child: const Text('인증확인', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF5E4AD); 
    const Color waveColor = Color(0xFFFFF9E3);

    return Scaffold(
      backgroundColor: bgColor,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: WaveBackground(
              waveColor: waveColor, 
              waveHeightFactor: _currentWaveHeight
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(RemixIcons.arrow_left_line, color: Colors.black87),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        children: [
                          const SizedBox(height: 40),
                          // 🔥 일관된 진입 애니메이션 적용
                          FadeSlideTransition(
                            delay: 0.0,
                            child: const Icon(
                              RemixIcons.lock_password_line,
                              size: 80,
                              color: Color(0xFF8B6B23),
                            ),
                          ),
                          const SizedBox(height: 30),
                          FadeSlideTransition(
                            delay: 0.2,
                            child: const Text(
                              '가입 시 사용한 이메일을 입력해주세요.\n인증번호를 보내드립니다.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
                            ),
                          ),
                          const SizedBox(height: 50),
                          FadeSlideTransition(
                            delay: 0.4,
                            child: _buildUnderlineTextField(),
                          ),
                          const SizedBox(height: 40),
                          FadeSlideTransition(
                            delay: 0.6,
                            child: _buildPrimaryButton(),
                          ),
                          const SizedBox(height: 50),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Helper (중복 제거를 위해 메서드로 분리) ---
  Widget _buildUnderlineTextField() {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: _emailController,
        focusNode: _emailFocusNode,
        decoration: const InputDecoration(
          prefixIcon: Icon(RemixIcons.mail_fill, size: 20, color: Colors.black45),
          prefixIconConstraints: BoxConstraints(minWidth: 35),
          hintText: '이메일 주소',
          hintStyle: TextStyle(color: Colors.black38),
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12, width: 1)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2)),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: 300,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          _isLoading ? '전송 중...' : '인증요청',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}