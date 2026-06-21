import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../design/app_colors.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';
import 'vocabulary_provider.dart';
import 'widgets/vocabulary_widgets.dart';
import '../../services/tts_service.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final TextEditingController _answerController = TextEditingController();
  int? _lastQuizId;
  bool _sessionReady = false;

  Future<void> _speakCurrentSentence(
    GrammarProvider provider,
    Map<String, dynamic> quiz,
  ) async {
    final masked = (quiz['masked_sentence'] ?? '').toString();
    await TtsService().init();
    if (!mounted) return;

    if (provider.targetWord != null && provider.targetWord!.isNotEmpty) {
      final text = masked.replaceAll('____', provider.targetWord!);
      await TtsService().speak(text);
    } else {
      await TtsService().speakWithBlankPause(masked);
    }
  }

  @override
  void initState() {
    super.initState();
    TtsService().init();
    _answerController.addListener(_refreshInputWidth);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await TtsService().stop();
      if (!mounted) return;
      final args =
          Get.arguments ??
          {'new_count': 5, 'review_count': 10, 'retry_count': 10};
      await Provider.of<GrammarProvider>(context, listen: false).fetchQuiz(
        args['new_count'],
        args['review_count'],
        args['retry_count'],
      );
      if (mounted) {
        setState(() => _sessionReady = true);
      }
    });
  }

  @override
  void dispose() {
    TtsService().stop();
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

    if (_sessionReady &&
        quiz != null &&
        quiz['sentence_id'] != _lastQuizId) {
      _lastQuizId = quiz['sentence_id'];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_sessionReady) return;
        _speakCurrentSentence(provider, quiz);
      });
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: !_sessionReady || provider.isLoading
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
            '오늘의 어휘는?',
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
                constraints: const BoxConstraints(minHeight: 190),
                child: SizedBox(
                  height: 190,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(30, 52, 30, 26),
                        child: Text.rich(
                          _highlightedKorean(quiz),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            height: 1.45,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: '영어 다시 듣기',
                              icon: const Icon(
                                Icons.volume_up_rounded,
                                color: AuthColors.primary,
                              ),
                              onPressed: () async {
                                await _speakCurrentSentence(provider, quiz);
                              },
                            ),
                            IconButton(
                              tooltip: '북마크',
                              icon: Icon(
                                provider.isCurrentBookmarked
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: AuthColors.primary,
                              ),
                              onPressed: provider.isBookmarking
                                  ? null
                                  : () => provider.toggleBookmark(),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                  mainAxisSize: MainAxisSize.min, // 🌟 레이아웃 꼬임 방지
                  children: [
                    _buildInputArea(
                      provider,
                      (quiz['masked_sentence'] ?? '').toString(),
                    ),

                    // 🌟 핵심: canRetry 변수로 상태를 확실하게 구분합니다.
                    if (provider.isWrong) ...[
                      const SizedBox(height: 16),
                      
                      // 1. 재시도 기회가 남았다면 -> 힌트만 보여줌
                      if (provider.canRetry && provider.currentHint != null)
                        HintBox(hint: provider.currentHint!),

                      // 2. 재시도 기회가 끝났다면 -> 정답을 보여줌
                      if (!provider.canRetry && provider.targetWord != null)
                        _CorrectAnswerBox(answer: provider.targetWord!),
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
    final target = (quiz['target_word_ko'] ?? '').toString().trim();
    final highlightedText = _findKoreanHighlight(text, target, quiz);
    if (highlightedText.isEmpty) {
      return TextSpan(text: text);
    }

    final match = RegExp(
      '${RegExp.escape(highlightedText)}[\\uAC00-\\uD7A3]*',
    ).firstMatch(text);
    if (match == null) {
      return TextSpan(text: text);
    }

    final index = match.start;
    final matchedText = match.group(0) ?? highlightedText;
    return TextSpan(
      children: [
        TextSpan(text: text.substring(0, index)),
        TextSpan(
          text: matchedText,
          style: const TextStyle(
            color: Color(0xFFFF8A00),
            fontWeight: FontWeight.w900,
          ),
        ),
        TextSpan(text: text.substring(index + matchedText.length)),
      ],
    );
  }

  String _findKoreanHighlight(
    String koreanText,
    String target,
    Map<String, dynamic> quiz,
  ) {
    if (target.isNotEmpty && koreanText.contains(target)) {
      return target;
    }

    final words = RegExp(r'[\uAC00-\uD7A3]+')
        .allMatches(koreanText)
        .map((match) => match.group(0) ?? '')
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '';

    final maskedSentence = (quiz['masked_sentence'] ?? '').toString();
    final blankIndex = maskedSentence.indexOf('____');
    if (blankIndex <= 0) return words.first;

    final sentenceLength = maskedSentence.replaceAll('____', '').length;
    final ratio = sentenceLength == 0 ? 0.0 : blankIndex / sentenceLength;
    final wordIndex = (ratio * (words.length - 1)).round();
    return words[wordIndex.clamp(0, words.length - 1).toInt()];
  }

  Widget _buildInputArea(GrammarProvider provider, String maskedSentence) {
    final parts = maskedSentence.split('____');
    final before = parts.isNotEmpty ? parts.first.trim() : '';
    final after = parts.length > 1 ? parts.sublist(1).join('____').trim() : '';
    const sentenceStyle = TextStyle(
      color: Color(0xFF211A19),
      fontSize: 17,
      height: 1.45,
      fontWeight: FontWeight.w800,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      runSpacing: 8,
      children: [
        ..._buildSentenceWords(before, sentenceStyle),
        LayoutBuilder(
          builder: (context, constraints) {
            final textPainter = TextPainter(
              text: TextSpan(
                text: _answerController.text.isEmpty
                    ? '____'
                    : '${_answerController.text}  ',
                style: sentenceStyle,
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
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
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
        ..._buildSentenceWords(after, sentenceStyle),
      ],
    );
  }

  List<Widget> _buildSentenceWords(String text, TextStyle style) {
    if (text.isEmpty) return const [];

    return text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .map((word) => Text(word, textAlign: TextAlign.center, style: style))
        .toList();
  }

  void _handleAction(GrammarProvider provider) {
    if (provider.isChecking) return;

    if (!provider.canRetry) {
       _speakCurrentSentence(provider, provider.currentQuiz!); // 오답 후 정답 공개 시 읽기
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


// 🔥 추가된 정답 표시 위젯
class _CorrectAnswerBox extends StatelessWidget {
  final String answer;

  const _CorrectAnswerBox({required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            const TextSpan(
              text: '정답: ',
              style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blue),
            ),
            TextSpan(
              text: answer,
              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.blue),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
