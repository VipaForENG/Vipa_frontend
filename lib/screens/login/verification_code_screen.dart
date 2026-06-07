import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import 'auth_widgets.dart';

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
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _timer;
  int _remainingSeconds = 600;
  bool _isVerifying = false;
  bool _isResending = false;
  String? _codeError;

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
    // 인증번호 유효시간 10분을 화면에 표시하고, 재전송 시 같은 로직을 다시 시작한다.
    _timer?.cancel();
    setState(() => _remainingSeconds = 600);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 0) {
        timer.cancel();
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  String get _code => _controllers.map((controller) => controller.text).join();

  String get _timeText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _handleVerifyCode() async {
    if (_code.length != 6) {
      setState(() => _codeError = '인증번호를 모두 입력해주세요.');
      return;
    }

    setState(() {
      _isVerifying = true;
      _codeError = null;
    });

    final isVerified = await AuthController.verifyRecoveryCode(
      widget.email,
      _code,
    );
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (!isVerified) {
      setState(() => _codeError = '인증번호가 일치하지 않습니다.');
      return;
    }

    // 인증 성공 후 새 비밀번호 화면에서 reset API를 호출할 수 있도록 이메일과 코드를 전달한다.
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

  Future<void> _handleResendCode() async {
    setState(() {
      _isResending = true;
      _codeError = null;
    });

    final success = await AuthController.sendRecoveryCode(widget.email);
    if (!mounted) return;
    setState(() => _isResending = false);

    if (!success) {
      VipaSnackBar.show(context, '인증번호 재전송에 실패했습니다.', isError: true);
      return;
    }

    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
    _startTimer();
    VipaSnackBar.show(context, '인증번호를 다시 보냈습니다.');
  }

  void _handleDigitChanged(String value, int index) {
    setState(() => _codeError = null);

    // 한 자리 입력이 끝나면 다음 칸으로 포커스를 이동해 6자리 입력 UX를 자연스럽게 만든다.
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    if (_code.length == 6) {
      FocusScope.of(context).unfocus();
    }
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event, int index) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      horizontalPadding: 30,
      child: Column(
        children: [
          const SizedBox(height: 91),
          const Text(
            '인증번호를 보냈어요!',
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
            '휴대폰으로 확인해 주세요.',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 63),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              6,
              (index) => Padding(
                padding: EdgeInsets.only(right: index == 5 ? 0 : 7),
                child: _CodeBox(
                  controller: _controllers[index],
                  focusNode: _focusNodes[index],
                  onChanged: (value) => _handleDigitChanged(value, index),
                  onKeyEvent: (node, event) =>
                      _handleKeyEvent(node, event, index),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 23,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                _codeError ?? '',
                style: const TextStyle(
                  color: AuthColors.primary,
                  fontSize: 9,
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
                style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),
              const SizedBox(width: 21),
              Text(
                _timeText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AuthButton(
            text: _isVerifying ? '확인 중...' : '인증번호 입력',
            onPressed: _isVerifying || _isResending ? null : _handleVerifyCode,
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _isVerifying || _isResending ? null : _handleResendCode,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFB0B0B0),
                side: const BorderSide(color: Color(0xFFC8C8C8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _isResending ? '재전송 중...' : '인증번호 재전송',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const Spacer(),
        ],
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
      height: 36,
      child: Focus(
        onKeyEvent: onKeyEvent,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          cursorColor: AuthColors.primary,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            counterText: '',
            contentPadding: EdgeInsets.zero,
            filled: true,
            fillColor: Colors.white,
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
              borderSide: const BorderSide(color: AuthColors.primary, width: 2),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
