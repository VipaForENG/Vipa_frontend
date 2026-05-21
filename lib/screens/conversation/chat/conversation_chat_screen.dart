import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'conversation_provider.dart';
import 'conversation_result_screen.dart';
import 'widgets/conversation_widgets.dart';
import 'evaluation_detail_view.dart';

class ConversationChatScreen extends StatefulWidget {
  final int subCatId;
  const ConversationChatScreen({super.key, required this.subCatId});

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
      provider.initializeScenario(widget.subCatId, 1);
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: ConversationTopBar(value: provider.progress),
      ),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AiSpeechBubble(
                          en: provider.aiEnglish,
                          ko: provider.aiKorean,
                        ),
                        const SizedBox(height: 30),
                        _buildMissionBox(provider.userTargetSentence),
                        if (provider.hints.isNotEmpty && !provider.isAnswered)
                          ...provider.hints.map((hint) => _buildHintItem(hint)),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                _buildBottomArea(provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF263238), Color(0xFF1E1E2C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  Widget _buildHintItem(String text) {
    bool isWarning = text.contains("⚠️");
    bool isAnswer = text.contains("정답:");
    Color color = isWarning
        ? Colors.redAccent
        : (isAnswer ? Colors.greenAccent : const Color(0xFFB3A9FF));
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isWarning
                ? Icons.warning_amber_rounded
                : (isAnswer ? Icons.check_circle_outline : Icons.lightbulb),
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 15,
                fontWeight: (isWarning || isAnswer)
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✨ 하단 컨트롤 분기 영역
  Widget _buildBottomArea(ConversationProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: provider.isAnswered
          ? ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.5,
              ),
              child: EvaluationDetailView(provider: provider),
            )
          : _buildInputArea(provider),
    );
  }

  Widget _buildInputArea(ConversationProvider provider) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (provider.isRecording)
          _buildUserSpeechPreview(provider.userSpokenText),
        const SizedBox(height: 15),
        // ✨ 키보드 모드 분기
        provider.isTextMode
            ? _buildTextFieldInput(provider)
            : _buildInputButtons(provider),
      ],
    );
  }

  // ✨ 텍스트 입력 UI
  Widget _buildTextFieldInput(ConversationProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.mic_none, color: Colors.white70),
            onPressed: () => provider.toggleTextMode(),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Type your answer...",
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15),
              ),
              onSubmitted: (value) => _handleTextSubmit(provider),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Color(0xFF8877FF)),
            onPressed: () => _handleTextSubmit(provider),
          ),
        ],
      ),
    );
  }

  void _handleTextSubmit(ConversationProvider provider) {
    if (_textController.text.trim().isNotEmpty) {
      provider.evaluateSpeech(_textController.text.trim());
      _textController.clear();
    }
  }

  Widget _buildInputButtons(ConversationProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _circleButton(
          Icons.lightbulb_outline,
          () => provider.requestHintStepByStep(),
        ),
        _micButton(provider),
        _circleButton(
          Icons.keyboard_alt_outlined,
          () => provider.toggleTextMode(),
        ), // ✨ 모드 전환 버튼
      ],
    );
  }

  Widget _buildUserSpeechPreview(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Widget _micButton(ConversationProvider provider) {
    double scale = provider.dbScale;
    return GestureDetector(
      onTap: () => provider.toggleRecording(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: provider.isRecording
              ? Colors.redAccent
              : const Color(0xFF8877FF),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color:
                  (provider.isRecording
                          ? Colors.redAccent
                          : const Color(0xFF8877FF))
                      .withValues(alpha: 0.3 + (scale * 0.5)),
              blurRadius: 15 + (scale * 60),
              spreadRadius: 2 + (scale * 25),
            ),
          ],
        ),
        child: Icon(
          provider.isRecording ? Icons.stop : Icons.mic,
          color: Colors.white,
          size: 42,
        ),
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildMissionBox(String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
