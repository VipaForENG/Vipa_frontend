import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../design/app_colors.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';
import 'vocabulary_provider.dart';
import 'widgets/vocabulary_widgets.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _answerController.addListener(_refreshInputWidth);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          Get.arguments ??
          {'new_count': 5, 'review_count': 10, 'retry_count': 10};
      Provider.of<GrammarProvider>(context, listen: false).fetchQuiz(
        args['new_count'],
        args['review_count'],
        args['retry_count'],
      );
    });
  }

  @override
  void dispose() {
    _answerController.removeListener(_refreshInputWidth);
    _answerController.dispose();
    super.dispose();
  }

  void _refreshInputWidth() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GrammarProvider>(context);
    final quiz = provider.currentQuiz;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : quiz == null
            ? const SizedBox.shrink()
            : _buildQuizBody(provider, quiz),
      ),
    );
  }

  Widget _buildQuizBody(GrammarProvider provider, Map<String, dynamic> quiz) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 32),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
        Container(
          width: double.infinity,
          height: 60,
          alignment: Alignment.center,
          color: Colors.white,
          child: const Text(
            '오늘의 어휘 목표량',
            style: TextStyle(
              color: AuthColors.primary,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 46),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: provider.totalCount == 0
                  ? 0
                  : provider.currentCount / provider.totalCount,
              minHeight: 8,
              backgroundColor: const Color(0xFFDADADA),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AuthColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 104),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Text.rich(
                  _highlightedKorean(quiz),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(minHeight: 112),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF1EF),
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(8),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInputArea(
                      provider,
                      (quiz['masked_sentence'] ?? '').toString(),
                    ),
                    if (provider.isWrong && provider.currentHint != null) ...[
                      const SizedBox(height: 16),
                      HintBox(hint: provider.currentHint!),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!provider.canRetry) ...[
          const SizedBox(height: 18),
          SizedBox(
            width: MediaQuery.sizeOf(context).width - 104,
            height: 56,
            child: ElevatedButton(
              onPressed: provider.isChecking
                  ? null
                  : () => _handleAction(provider),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: AuthColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '다음 문제로 넘어가기',
                maxLines: 1,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
              ],
            ),
          ),
        );
      },
    );
  }

  TextSpan _highlightedKorean(Map<String, dynamic> quiz) {
    final text = (quiz['korean_hint'] ?? '').toString();
    final target = (quiz['target_word_ko'] ?? '').toString();
    if (target.isEmpty || !text.contains(target)) {
      return TextSpan(text: text);
    }

    final index = text.indexOf(target);
    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, index)),
        TextSpan(
          text: target,
          style: const TextStyle(color: AuthColors.primary),
        ),
        TextSpan(text: text.substring(index + target.length)),
      ],
    );
  }

  Widget _buildInputArea(GrammarProvider provider, String maskedSentence) {
    final parts = maskedSentence.split('____');
    final before = parts.isNotEmpty ? parts.first : '';
    final after = parts.length > 1 ? parts.sublist(1).join('____') : '';

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(before, style: const TextStyle(fontSize: 15)),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final textPainter = TextPainter(
              text: TextSpan(
                text: _answerController.text.isEmpty
                    ? '____'
                    : '${_answerController.text}  ',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              maxLines: 1,
              textDirection: TextDirection.ltr,
              textScaler: MediaQuery.textScalerOf(context),
            )..layout();
            final inputWidth = (textPainter.width + 32).clamp(
              52.0,
              MediaQuery.sizeOf(context).width * 0.82,
            ).toDouble();

            return SizedBox(
              width: inputWidth,
              child: TextField(
                controller: _answerController,
                enabled: !provider.isChecking && provider.canRetry,
                textAlign: TextAlign.center,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleAction(provider),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.only(bottom: 2),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: provider.isWrong
                          ? AuthColors.primary
                          : Colors.black87,
                      width: 1.3,
                    ),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: AuthColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(after, style: const TextStyle(fontSize: 15)),
        ),
      ],
    );
  }

  void _handleAction(GrammarProvider provider) {
    if (provider.isChecking) return;

    if (!provider.canRetry) {
      _answerController.clear();
      provider.forceNextQuestion(() {}, () => _finishQuiz(provider));
      return;
    }

    provider.checkAnswer(
      _answerController.text,
      () {
        _answerController.clear();
        VipaSnackBar.show(context, '정답입니다.');
      },
      () => _finishQuiz(provider),
      () => VipaSnackBar.show(context, '정답을 확인하고 다음 문제로 넘어가세요.'),
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
            'correct_count': 0,
            'score_percentage': 0.0,
            'results': [],
          },
    );
  }
}
