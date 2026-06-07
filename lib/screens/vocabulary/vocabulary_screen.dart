import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';
import 'vocabulary_provider.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _showHint = false;
  Object? _visibleQuizId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final routeArgs = ModalRoute.of(context)?.settings.arguments;
      final args = routeArgs is Map
          ? routeArgs
          : Get.arguments ??
                {'new_count': 5, 'review_count': 0, 'retry_count': 0};

      Provider.of<GrammarProvider>(context, listen: false).fetchQuiz(
        args['new_count'] ?? 5,
        args['review_count'] ?? 0,
        args['retry_count'] ?? 0,
      );
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GrammarProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AuthColors.primary),
                  )
                : _buildQuizBody(provider),
          ),
        ),
      ),
    );
  }

  Widget _buildQuizBody(GrammarProvider provider) {
    final quiz = provider.currentQuiz;
    if (quiz == null) return const SizedBox.shrink();

    final quizId = quiz['sentence_id'];
    if (_visibleQuizId != quizId) {
      _visibleQuizId = quizId;
      _showHint = false;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      child: Column(
        children: [
          const Text(
            '오늘의 어휘 목표량',
            style: TextStyle(
              color: AuthColors.primary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 31),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: provider.totalCount == 0
                    ? 0
                    : (provider.currentCount / provider.totalCount)
                          .clamp(0.0, 1.0)
                          .toDouble(),
                minHeight: 7,
                backgroundColor: const Color(0xFFE2E2E2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AuthColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          _VocabularyQuizCard(
            quiz: quiz,
            controller: _answerController,
            isWrong: provider.isWrong,
            enabled: !provider.isChecking && provider.canRetry,
            isChecking: provider.isChecking,
            onSubmit: () => _handleAction(provider),
          ),
          if (provider.isWrong && provider.currentHint != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _showHint
                  ? _HintMessageCard(message: provider.currentHint!)
                  : _HintMessageButton(
                      onPressed: () {
                        setState(() {
                          _showHint = true;
                        });
                      },
                    ),
            ),
          const Spacer(),
        ],
      ),
    );
  }

  void _handleAction(GrammarProvider provider) {
    if (!provider.canRetry) {
      _answerController.clear();
      setState(() {
        _showHint = false;
      });
      provider.forceNextQuestion(() {}, () => _finishQuiz(provider));
      return;
    }

    provider.checkAnswer(
      _answerController.text,
      () {
        _answerController.clear();
        setState(() {
          _showHint = false;
        });
        VipaSnackBar.show(context, '정답입니다! 다음 문제로 갑니다!');
      },
      () {
        _finishQuiz(provider);
      },
      () {
        VipaSnackBar.show(context, '기회를 모두 소진했습니다. 정답을 확인하세요!');
        _answerController.text = provider.targetWord ?? '';
        setState(() {
          _showHint = false;
        });
      },
    );
  }

  void _finishQuiz(GrammarProvider provider) {
    _answerController.clear();
    Get.offNamed(
      AppRoutes.vocabularyResult,
      arguments:
          provider.completionResult ??
          {
            'total_count': provider.totalCount,
            'correct_count': provider.totalCount,
            'results': [],
          },
    );
  }
}

class _VocabularyQuizCard extends StatelessWidget {
  const _VocabularyQuizCard({
    required this.quiz,
    required this.controller,
    required this.isWrong,
    required this.enabled,
    required this.isChecking,
    required this.onSubmit,
  });

  final Map<String, dynamic> quiz;
  final TextEditingController controller;
  final bool isWrong;
  final bool enabled;
  final bool isChecking;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final hint = quiz['korean_hint']?.toString() ?? '';
    final maskedSentence = quiz['masked_sentence']?.toString() ?? '';
    final target = quiz['target_word']?.toString();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 33, 18, 31),
            child: _HighlightedKoreanHint(text: hint, target: target),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 31, 18, 31),
            color: const Color(0xFFFFF0EE),
            child: _SentenceInputLine(
              maskedSentence: maskedSentence,
              controller: controller,
              enabled: enabled,
              isWrong: isWrong,
              onSubmit: onSubmit,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: isChecking ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AuthColors.primary,
                  disabledBackgroundColor: AuthColors.primary.withValues(
                    alpha: 0.45,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  isChecking ? '확인 중...' : '확인',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HintMessageButton extends StatelessWidget {
  const _HintMessageButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 156,
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AuthColors.primary,
          side: const BorderSide(color: AuthColors.primary, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: const Text(
          '힌트메세지',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _HintMessageCard extends StatelessWidget {
  const _HintMessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 92),
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFC8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          height: 1.4,
        ),
      ),
    );
  }
}

class _HighlightedKoreanHint extends StatelessWidget {
  const _HighlightedKoreanHint({required this.text, this.target});

  final String text;
  final String? target;

  @override
  Widget build(BuildContext context) {
    if (target == null || target!.isEmpty || !text.contains(target!)) {
      return Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      );
    }

    final parts = text.split(target!);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: parts.first),
          TextSpan(
            text: target,
            style: const TextStyle(color: AuthColors.primary),
          ),
          TextSpan(text: parts.skip(1).join(target!)),
        ],
      ),
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 13,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SentenceInputLine extends StatelessWidget {
  const _SentenceInputLine({
    required this.maskedSentence,
    required this.controller,
    required this.enabled,
    required this.isWrong,
    required this.onSubmit,
  });

  final String maskedSentence;
  final TextEditingController controller;
  final bool enabled;
  final bool isWrong;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final parts = maskedSentence.split('____');
    final before = parts.isNotEmpty ? parts.first : '';
    final after = parts.length > 1 ? parts.sublist(1).join('____') : '';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      alignment: WrapAlignment.center,
      children: [
        Text(
          before,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(
          width: 106,
          child: TextField(
            controller: controller,
            enabled: enabled,
            textAlign: TextAlign.center,
            cursorColor: AuthColors.primary,
            onSubmitted: (_) => onSubmit(),
            style: TextStyle(
              color: isWrong ? AuthColors.primary : Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.only(bottom: 2),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AuthColors.primary, width: 2),
              ),
            ),
          ),
        ),
        Text(
          after,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
