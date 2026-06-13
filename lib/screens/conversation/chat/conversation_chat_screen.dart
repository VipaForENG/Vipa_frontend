import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../login/auth_widgets.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ConversationProvider>(
        context,
        listen: false,
      );
      provider.reset();
      provider.initializeScenario(widget.subCatId);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ConversationProvider>(context);

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
      body: SafeArea(
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
                const SizedBox(height: 17),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: _LearningCard(
                    english: provider.aiEnglish,
                    korean: provider.aiKorean,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 17),
                  child: _MissionBox(text: provider.userTargetSentence),
                ),
                if (provider.isTextMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 14, 17, 0),
                    child: _TextAnswerBox(
                      controller: _textController,
                      onMicTap: provider.toggleTextMode,
                      onSubmit: () => _handleTextSubmit(provider),
                    ),
                  ),
                if (provider.isAnswered)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(17, 14, 17, 0),
                    child: _FeedbackBox(
                      feedback: provider.feedbackKo,
                      corrected: provider.correctedEn,
                      onNext: provider.nextStep,
                    ),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 124),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoundToolButton(
                        icon: Icons.lightbulb,
                        onTap: () => _showHint(provider),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleTextSubmit(ConversationProvider provider) {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    provider.evaluateSpeech(text);
    _textController.clear();
  }

  Future<void> _showHint(ConversationProvider provider) async {
    await provider.requestHintStepByStep(textController: _textController);
    if (!mounted || provider.hints.isEmpty) return;

    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 7),
        backgroundColor: const Color(0xFFFFFFC9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 128),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Center(
              child: Text(
                _hintMessage(provider),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _hintMessage(ConversationProvider provider) {
    if (provider.currentHintLevel == 3) {
      return '한 번 더 누르면 정답이 입력창에 자동 완성됩니다.';
    }

    final hint = provider.hints.last;
    final separator = hint.indexOf(': ');
    return separator == -1 ? hint : hint.substring(separator + 2);
  }
}

class _LearningCard extends StatelessWidget {
  const _LearningCard({required this.english, required this.korean});

  final String english;
  final String korean;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 128),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: _cardDecoration(Colors.white),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
    required this.onMicTap,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final VoidCallback onMicTap;
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
          IconButton(
            onPressed: onMicTap,
            icon: const Icon(Icons.mic, color: AuthColors.primary),
          ),
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

class _FeedbackBox extends StatelessWidget {
  const _FeedbackBox({
    required this.feedback,
    required this.corrected,
    required this.onNext,
  });

  final String feedback;
  final String corrected;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          Text(
            feedback.isEmpty ? '답변을 확인했습니다.' : feedback,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
          ),
          if (corrected.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              corrected,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AuthColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AuthColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                '다음으로',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
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
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ],
  );
}
