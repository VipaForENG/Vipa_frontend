import 'package:flutter/material.dart';

import '../../controllers/ai_controller.dart';
import '../login/auth_widgets.dart';
import 'widgets/voice_wave.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final AiController _controller = AiController();
  final TextEditingController _textController = TextEditingController();
  bool _hasStartedTalking = false;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const _AiFreeTalkingHeader(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                    child: Stack(
                      children: [
                        ListView(
                          padding: const EdgeInsets.only(bottom: 142),
                          children: [
                            const _ChatBubble(
                              english:
                                  'Thank you. What is the purpose of your visit to our country?',
                              korean: '감사합니다. 우리나라를 방문한 목적이 무엇인가요?',
                              alignment: Alignment.centerLeft,
                            ),
                            const SizedBox(height: 12),
                            const _ChatBubble(
                              english:
                                  'I came here for sightseeing. I plan to travel and see the city.',
                              korean: '',
                              alignment: Alignment.centerRight,
                              isUser: true,
                            ),
                            const SizedBox(height: 12),
                            const _ChatBubble(
                              english: 'I have checked. Have a pleasant trip.',
                              korean: '확인했습니다. 즐거운 여행되세요.',
                              alignment: Alignment.centerLeft,
                            ),
                            if (_controller.isLoading) ...[
                              const SizedBox(height: 16),
                              const Center(
                                child: CircularProgressIndicator(
                                  color: AuthColors.primary,
                                ),
                              ),
                            ] else if (_hasStartedTalking &&
                                _controller.aiEnText.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _ChatBubble(
                                english: _controller.aiEnText,
                                korean: _controller.aiKoText,
                                alignment: Alignment.centerLeft,
                              ),
                            ],
                          ],
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 42),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                _RoundActionButton(
                                  size: 72,
                                  color: AuthColors.primary,
                                  icon: Icons.mic_none_rounded,
                                  iconSize: 43,
                                  onPressed: _openVoiceSheet,
                                ),
                                const SizedBox(width: 17),
                                _RoundActionButton(
                                  size: 46,
                                  color: const Color(0xFFFF907D),
                                  icon: Icons.keyboard_alt_outlined,
                                  iconSize: 24,
                                  onPressed: _openTextSheet,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openVoiceSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: VoiceWaveView(
              onTextRecognized: (text) {
                if (text.trim().isNotEmpty) {
                  setState(() => _hasStartedTalking = true);
                  _controller.sendToAi(text.trim());
                }
              },
            ),
          ),
        );
      },
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
                    cursorColor: AuthColors.primary,
                    decoration: InputDecoration(
                      hintText: '영어로 말할 내용을 입력하세요',
                      filled: true,
                      fillColor: AuthColors.input,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AuthColors.primary),
                      ),
                    ),
                    onSubmitted: (_) => _sendTypedMessage(context),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: () => _sendTypedMessage(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AuthColors.primary,
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
    setState(() => _hasStartedTalking = true);
    _controller.sendToAi(text);
  }
}

class _AiFreeTalkingHeader extends StatelessWidget {
  const _AiFreeTalkingHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: const Text(
        'AI프리토킹',
        style: TextStyle(
          color: AuthColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.english,
    required this.korean,
    required this.alignment,
    this.isUser = false,
  });

  final String english;
  final String korean;
  final Alignment alignment;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 330),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 10, 13, 10),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFFFF8B76) : Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              Text(
                english,
                textAlign: isUser ? TextAlign.right : TextAlign.left,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  height: 1.13,
                ),
              ),
              if (korean.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  korean,
                  textAlign: isUser ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color: isUser
                        ? Colors.white.withValues(alpha: 0.82)
                        : const Color(0xFFBABABA),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1.15,
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
    required this.size,
    required this.color,
    required this.icon,
    required this.iconSize,
    required this.onPressed,
  });

  final double size;
  final Color color;
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          elevation: 0,
          shape: const CircleBorder(),
        ),
        child: Icon(icon, size: iconSize),
      ),
    );
  }
}
