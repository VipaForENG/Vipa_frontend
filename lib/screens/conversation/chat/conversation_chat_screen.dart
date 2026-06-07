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
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const SizedBox(height: 18),
                const Text(
                  '실전회화 학습',
                  style: TextStyle(
                    color: AuthColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: provider.progress,
                      minHeight: 7,
                      backgroundColor: const Color(0xFFE2E2E2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AuthColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _LearningCard(
                    english: provider.aiEnglish,
                    korean: provider.aiKorean,
                  ),
                ),
                const SizedBox(height: 14),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _MissionBox(text: provider.userTargetSentence),
                ),
                if (provider.isTextMode)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _TextAnswerBox(
                      controller: _textController,
                      onMicTap: provider.toggleTextMode,
                      onSubmit: () => _handleTextSubmit(provider),
                    ),
                  ),
                if (provider.isAnswered)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _FeedbackBox(
                      feedback: provider.feedbackKo,
                      corrected: provider.correctedEn,
                      onNext: provider.nextStep,
                    ),
                  ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 44),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _RoundToolButton(
                        icon: Icons.lightbulb,
                        onTap: () => provider.requestHintStepByStep(
                          textController: _textController,
                        ),
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
}

class _LearningCard extends StatelessWidget {
  const _LearningCard({required this.english, required this.korean});

  final String english;
  final String korean;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            english,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            korean,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF8C8C8C),
              fontSize: 11,
              fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFF806B),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text.isEmpty ? '문장을 듣고 답변해 보세요.' : text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w900,
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
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            feedback.isEmpty ? '답변을 확인했습니다.' : feedback,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
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
                backgroundColor: AuthColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
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
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: Color(0xFFFF806B),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 25),
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
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: provider.isRecording ? Colors.redAccent : AuthColors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(
          provider.isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }
}
