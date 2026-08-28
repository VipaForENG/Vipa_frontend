import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../../controllers/ai_controller.dart';
import '../../design/app_colors.dart';
import '../../services/tts_service.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final AiController _controller = AiController();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isListening = false;
  String _spokenText = '';
  int _knownMessageCount = 0;

  @override
  void initState() {
    super.initState();
    _knownMessageCount = _controller.messages.length;
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final messages = _controller.messages;
    if (messages.length > _knownMessageCount) {
      final newMessages = messages.skip(_knownMessageCount);
      final newAiMessages = newMessages
          .where((message) => !message.isUser && message.text.isNotEmpty)
          .toList();
      _knownMessageCount = messages.length;

      if (newAiMessages.isNotEmpty) {
        _speakAiMessage(newAiMessages.last.text);
      }
    }
    setState(() {});
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _speech.stop();
    TtsService().stop();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(14, 18, 14, 130),
                    itemCount:
                        _controller.messages.length +
                        (_isListening && _spokenText.isNotEmpty ? 1 : 0) +
                        (_controller.isLoading ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index < _controller.messages.length) {
                        final message = _controller.messages[index];
                        return _ChatBubble(
                          text: message.text,
                          translation: message.translation,
                          alignRight: message.isUser,
                          onSpeak: message.isUser
                              ? null
                              : () => _speakAiMessage(message.text),
                        );
                      }
                      if (_isListening &&
                          _spokenText.isNotEmpty &&
                          index == _controller.messages.length) {
                        return _ChatBubble(
                          text: _spokenText,
                          translation: '듣고 있어요...',
                          alignRight: true,
                          onSpeak: null,
                        );
                      }
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: _TypingBubble(),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _RoundActionButton(
                            icon: _isListening
                                ? Icons.stop_rounded
                                : Icons.mic_none_rounded,
                            size: 76,
                            iconSize: 43,
                            isActive: _isListening,
                            onTap: _toggleListening,
                          ),
                          const SizedBox(height: 6),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 180),
                            child: Text(
                              _isListening ? '녹음 중 · 눌러서 전송' : '말하기',
                              key: ValueKey(_isListening),
                              style: TextStyle(
                                color: _isListening
                                    ? AppColors.primary
                                    : const Color(0xFF777777),
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
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

  Future<void> _toggleListening() async {
    if (_isListening) {
      await _finishListening();
      return;
    }

    await TtsService().stop();
    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마이크 권한이 필요합니다.')),
        );
      }
      return;
    }

    final available = await _speech.initialize(
      onStatus: (status) {
        if (_isListening && (status == 'done' || status == 'notListening')) {
          _finishListening();
        }
      },
      onError: (_) {
        if (_isListening) _finishListening();
      },
    );
    if (!available || !mounted) return;

    setState(() {
      _spokenText = '';
      _isListening = true;
    });
    await _speech.listen(
      onResult: (result) {
        if (!mounted) return;
        setState(() => _spokenText = result.recognizedWords);
        _scrollToBottom();
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: 'en_US',
        pauseFor: const Duration(seconds: 3),
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: false,
      ),
    );
  }

  Future<void> _finishListening() async {
    if (!_isListening) return;
    final message = _spokenText.trim();
    setState(() {
      _isListening = false;
      _spokenText = '';
    });
    await _speech.stop();
    if (message.isNotEmpty) {
      _controller.sendToAi(message);
    }
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
                      hintText: '영어로 말할 내용을 입력하세요.',
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

  Future<void> _speakAiMessage(String text) async {
    final english = text.trim();
    if (english.isEmpty) return;
    await TtsService().init();
    if (!mounted || _isListening) return;
    await TtsService().speak(english);
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.text,
    required this.translation,
    required this.alignRight,
    required this.onSpeak,
  });

  final String text;
  final String translation;
  final bool alignRight;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 292),
        child: Container(
          decoration: BoxDecoration(
            color: alignRight ? const Color(0xFFFF806B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  11,
                  10,
                  onSpeak == null ? 11 : 42,
                  8,
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
              if (onSpeak != null)
                Positioned(
                  top: 2,
                  right: 3,
                  child: IconButton(
                    tooltip: '영어 다시 듣기',
                    onPressed: onSpeak,
                    icon: const Icon(
                      Icons.volume_up_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
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
    this.isActive = false,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 0,
                  spreadRadius: 8,
                ),
              ]
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFFD93624) : AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}
