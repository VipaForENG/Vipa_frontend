import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/auth_controller.dart';
import '../../design/app_colors.dart';
import '../../routes/app_routes.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({
    super.key,
    required this.email,
    this.isFromMyPage = false,
  });

  final String email;
  final bool isFromMyPage;

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 600;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _codeError;

  String get _code => _controllers.map((item) => item.text).join();
  String get _timeText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 600;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds == 0) {
        timer.cancel();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _onDigitChanged(String value, int index) {
    setState(() => _codeError = null);
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_code.length == 6) FocusScope.of(context).unfocus();
  }

  KeyEventResult _onKeyEvent(FocusNode _, KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Future<void> _verify() async {
    if (_code.length != 6) {
      setState(() => _codeError = '인증번호를 확인해주세요!');
      return;
    }
    setState(() {
      _isVerifying = true;
      _codeError = null;
    });
    final verified = await AuthController.verifyRecoveryCode(widget.email, _code);
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (!verified) {
      setState(() => _codeError = '인증번호를 확인해주세요!');
      return;
    }
    Navigator.pushNamed(
      context,
      AppRoutes.changePassword,
      arguments: <String, dynamic>{
        'email': widget.email,
        'code': _code,
        'isFromMyPage': widget.isFromMyPage,
      },
    );
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _codeError = null;
    });
    final success = await AuthController.sendRecoveryCode(widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);
    if (!success) {
      setState(() => _codeError = '인증번호 재전송에 실패했습니다.');
      return;
    }
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    setState(_startTimer);
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
                    constraints: const BoxConstraints(maxWidth: 350),
                    child: Column(
                      children: [
                        const SizedBox(height: 160),
                        const Text(
                          '인증번호를 보냈어요!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 32,
                            height: 1,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '휴대폰을 확인해 주세요!',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 110),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            6,
                            (index) => _CodeBox(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              onChanged: (value) => _onDigitChanged(value, index),
                              onKeyEvent: (node, event) =>
                                  _onKeyEvent(node, event, index),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              _codeError ?? '',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '유효시간',
                              style: TextStyle(
                                color: Color(0xFF777777),
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              _timeText,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 23),
                        _VerificationButton(
                          text: _isVerifying ? '확인 중...' : '인증번호 입력',
                          filled: true,
                          onPressed:
                              _isVerifying || _isResending ? null : _verify,
                        ),
                        const SizedBox(height: 13),
                        _VerificationButton(
                          text: _isResending ? '재전송 중...' : '인증번호 재전송',
                          onPressed:
                              _isVerifying || _isResending ? null : _resend,
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

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final FocusOnKeyEventCallback onKeyEvent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 48,
      child: Focus(
        onKeyEvent: onKeyEvent,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          cursorColor: AppColors.primary,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _VerificationButton extends StatelessWidget {
  const _VerificationButton({
    required this.text,
    required this.onPressed,
    this.filled = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 212,
      height: 56,
      child: filled
          ? ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AppColors.primary,
                disabledBackgroundColor:
                    AppColors.primary.withValues(alpha: 0.65),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            )
          : OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB7B7B7),
                side: const BorderSide(color: Color(0xFFB7B7B7)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
    );
  }
}
