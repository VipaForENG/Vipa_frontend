import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../login/auth_widgets.dart';
import '../../../services/tts_service.dart';
import 'conversation_provider.dart';
import 'conversation_result_screen.dart';

class ConversationChatScreen extends StatefulWidget {
  const ConversationChatScreen({super.key, required this.subCatId});

  final int subCatId;

  @override
  State<ConversationChatScreen> createState() => _ConversationChatScreenState();
}

class _ConversationChatScreenState extends State<ConversationChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final PageController _hintPageController = PageController(viewportFraction: .9);
  int _hintPage = 0;
  String? _lastSpokenEnglish;
  bool _sessionReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TtsService().stop();
      if (!mounted) return;
      final provider = Provider.of<ConversationProvider>(
        context,
        listen: false,
      );
      provider.reset();
      await provider.initializeScenario(widget.subCatId);
      if (mounted) {
        setState(() => _sessionReady = true);
      }
    });
  }

  @override
  void dispose() {
    TtsService().stop();
    _textController.dispose();
    _hintPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConversationProvider>();
    final english = provider.aiEnglish.trim();

    if (_sessionReady &&
        english.isNotEmpty &&
        english != '시나리오를 생성 중입니다...' &&
        english != _lastSpokenEnglish) {
      _lastSpokenEnglish = english;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _speakEnglish(english);
      });
    }

    if (provider.completionResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final result = provider.completionResult!;
        provider.completionResult = null;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationResultScreen(result: result),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: Column(
                  children: [
                Container(
                  width: double.infinity,
                  height: 66,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: const Text(
                    '실전회화 학습',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(17, 17, 17, 28),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 33),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(99),
                            child: LinearProgressIndicator(
                              value: provider.progress,
                              minHeight: 8,
                              backgroundColor: const Color(0xFFE0E0E0),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AuthColors.primary,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 17),
                        _LearningCard(
                          english: provider.aiEnglish,
                          korean: provider.aiKorean,
                          onSpeak: () => _speakEnglish(provider.aiEnglish),
                        ),
                        const SizedBox(height: 12),
                        _MissionBox(text: provider.userTargetSentence),
                        if (provider.hints.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          _HintCarousel(
                            hints: provider.hints,
                            currentPage: _hintPage,
                            controller: _hintPageController,
                            onPageChanged: (page) {
                              setState(() => _hintPage = page);
                            },
                          ),
                        ],
                        if (provider.isTextMode) ...[
                          const SizedBox(height: 14),
                          _TextAnswerBox(
                            controller: _textController,
                            onSubmit: () => _handleTextSubmit(provider),
                          ),
                        ],
                        const SizedBox(height: 34),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _RoundToolButton(
                              icon: Icons.lightbulb,
                              onTap: () => _requestHint(provider),
                            ),
                            const SizedBox(width: 20),
                            _MicButton(provider: provider),
                            const SizedBox(width: 20),
                            _RoundToolButton(
                              icon: Icons.keyboard,
                              onTap: provider.toggleTextMode,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                  ],
                ),
              ),
            ),
          ),
          if (provider.isAnswered)
            Positioned.fill(
              child: _FeedbackOverlay(
                feedback: provider.feedbackKo,
                corrected: provider.correctedEn,
                onNext: provider.nextStep,
              ),
            ),
        ],
      ),
    );
  }

  void _handleTextSubmit(ConversationProvider provider) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    provider.evaluateSpeech(text);
    _textController.clear();
  }

  Future<void> _speakEnglish(String text) async {
    final english = text.trim();
    if (english.isEmpty || english == '시나리오를 생성 중입니다...') return;
    await TtsService().init();
    if (!mounted) return;
    await TtsService().speak(english);
  }

  Future<void> _requestHint(ConversationProvider provider) async {
    final previousCount = provider.hints.length;
    await provider.requestHintStepByStep(textController: _textController);
    if (!mounted || provider.hints.length == previousCount) return;

    final lastPage = provider.hints.length - 1;
    setState(() => _hintPage = lastPage);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_hintPageController.hasClients) {
        _hintPageController.animateToPage(
          lastPage,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _HintCarousel extends StatelessWidget {
  const _HintCarousel({
    required this.hints,
    required this.currentPage,
    required this.controller,
    required this.onPageChanged,
  });

  final List<String> hints;
  final int currentPage;
  final PageController controller;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 104,
          child: PageView.builder(
            controller: controller,
            itemCount: hints.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFC9),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .12),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _displayHint(hints[index], index),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (hints.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              hints.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: index == currentPage ? 18 : 7,
                height: 7,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: index == currentPage
                      ? AuthColors.primary
                      : const Color(0xFFD4D4D4),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _displayHint(String hint, int index) {
    if (index == 2) {
      return '한 번 더 누르면 오답 처리됩니다.';
    }
    final separator = hint.indexOf(': ');
    return separator < 0 ? hint : hint.substring(separator + 2);
  }
}

class _LearningCard extends StatelessWidget {
  const _LearningCard({
    required this.english,
    required this.korean,
    required this.onSpeak,
  });

  final String english;
  final String korean;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 128),
      decoration: _cardDecoration(Colors.white),
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 48, 20, 25),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      english,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      korean,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 10,
            child: IconButton(
              tooltip: '영어 다시 듣기',
              onPressed: onSpeak,
              icon: const Icon(
                Icons.volume_up_rounded,
                color: AuthColors.primary,
                size: 27,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionBox extends StatelessWidget {
  const _MissionBox({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: _cardDecoration(const Color(0xFFFF806B)),
      child: Center(
        child: Text(
          text.isEmpty ? '문장을 듣고 따라 말해 보세요.' : text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _TextAnswerBox extends StatelessWidget {
  const _TextAnswerBox({
    required this.controller,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '답변을 입력하세요',
                border: InputBorder.none,
              ),
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          IconButton(
            onPressed: onSubmit,
            icon: const Icon(Icons.send, color: AuthColors.primary),
          ),
        ],
      ),
    );
  }
}

class _FeedbackOverlay extends StatelessWidget {
  const _FeedbackOverlay({
    required this.feedback,
    required this.corrected,
    required this.onNext,
  });

  final String feedback;
  final String corrected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: .48),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390, maxHeight: 560),
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'AI 피드백',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
                            feedback.isEmpty ? '답변을 확인했습니다.' : feedback,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 17,
                              height: 1.45,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (corrected.isNotEmpty) ...[
                            const SizedBox(height: 22),
                            Text(
                              corrected,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AuthColors.primary,
                                fontSize: 18,
                                height: 1.35,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: onNext,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AuthColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '다음으로',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundToolButton extends StatelessWidget {
  const _RoundToolButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Color(0xFFFF806B),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 27),
      ),
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({required this.provider});

  final ConversationProvider provider;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: provider.toggleRecording,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 102,
        height: 102,
        decoration: BoxDecoration(
          color: provider.isRecording ? Colors.redAccent : AuthColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          provider.isRecording ? Icons.stop : Icons.mic_none,
          color: Colors.white,
          size: 58,
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration(Color color) {
  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .2),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
