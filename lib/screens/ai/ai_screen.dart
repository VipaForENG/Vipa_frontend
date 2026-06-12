import 'package:flutter/material.dart';

import '../../controllers/ai_controller.dart';
import '../../design/app_colors.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final AiController _controller = AiController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final aiEnglish = _controller.aiEnText.isEmpty
        ? 'Thank you. What is the\npurpose of your visit to our country?'
        : _controller.aiEnText;
    final aiKorean = _controller.aiKoText.isEmpty
        ? '감사합니다. 우리나라를 방문한 목적이 무엇인가요?'
        : _controller.aiKoText;
    final feedback = _controller.aiFeedback;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'AI프리토킹',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 18, 14, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ChatBubble(
                        text: aiEnglish,
                        translation: aiKorean,
                        alignRight: false,
                      ),
                      if (feedback.isNotEmpty && feedback != 'N/A') ...[
                        const SizedBox(height: 18),
                        _ChatBubble(
                          text: feedback,
                          translation: '확인했습니다. 즐거운 여행되세요.',
                          alignRight: false,
                        ),
                      ],
                    ],
                  ),
                ),
                Align(
                  alignment: const Alignment(0, 0.68),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoundActionButton(
                        icon: Icons.mic_none_rounded,
                        size: 76,
                        iconSize: 43,
                        onTap: () {
                          // 음성 입력 기능은 기존 화면의 컨트롤러 호출을 유지하지 않고,
                          // 시안처럼 버튼 UI만 노출합니다.
                        },
                      ),
                      const SizedBox(width: 16),
                      _RoundActionButton(
                        icon: Icons.keyboard_alt_outlined,
                        size: 48,
                        iconSize: 24,
                        onTap: _openTextSheet,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTextSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    autofocus: true,
                    cursorColor: AppColors.primary,
                    decoration: const InputDecoration(
                      hintText: '영어로 말할 내용을 입력하세요',
                    ),
                    onSubmitted: (_) => _sendTypedMessage(context),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: () => _sendTypedMessage(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _sendTypedMessage(BuildContext sheetContext) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    Navigator.pop(sheetContext);
    _controller.sendToAi(text);
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.translation,
    required this.alignRight,
  });

  final String text;
  final String translation;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 292),
        child: Container(
          padding: const EdgeInsets.fromLTRB(11, 10, 11, 8),
          decoration: BoxDecoration(
            color: alignRight ? const Color(0xFFFF806B) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: alignRight ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              if (translation.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  translation,
                  style: TextStyle(
                    color: alignRight
                        ? Colors.white.withValues(alpha: 0.85)
                        : const Color(0xFF9B9B9B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    height: 1.05,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.size,
    required this.iconSize,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
