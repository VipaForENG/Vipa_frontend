import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// [도메인 및 디자인 임포트]
import 'vocabulary_provider.dart';
import 'widgets/vocabulary_widgets.dart';
import '../../design/snack_bar.dart';
import '../../design/background.dart';
import '../../design/animation_design.dart';
import '../../routes/app_routes.dart';
import '../../design/app_colors.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> {
  final TextEditingController _answerController = TextEditingController();
  Object? _visibleQuizId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          Get.arguments ??
          {'new_count': 5, 'review_count': 10, 'retry_count': 10};
      Provider.of<GrammarProvider>(
        context,
        listen: false,
      ).fetchQuiz(args['new_count'], args['review_count'], args['retry_count']);
    });
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  // 🌟 제출 및 다음으로 넘어가기 통합 핸들러
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
        VipaSnackBar.show(context, "정답입니다! 다음 문제로 갑니다! 🎉");
      },
      () {
        _finishQuiz(provider);
      },
      () {
        VipaSnackBar.show(context, "기회를 모두 소진했습니다. 정답을 확인하세요!");
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
            'correct_count': 0,
            'score_percentage': 0.0,
            'results': [],
          },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GrammarProvider>(context);
    final quiz = provider.currentQuiz;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: GrammarProgressBar(
          current: provider.currentCount,
          total: provider.totalCount,
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Background(
              fillLevel: 0.25,
              child: SafeArea(
                bottom: false,
                child: quiz == null
                    ? const SizedBox.shrink()
                    : _buildQuizBody(provider, quiz),
              ),
            ),
    );
  }

  Widget _buildQuizBody(GrammarProvider provider, Map<String, dynamic> quiz) {
    // 퀴즈 ID 변경 시 힌트 초기화
    final quizId = quiz['sentence_id'];
    if (_visibleQuizId != quizId) {
      _visibleQuizId = quizId;
    }

    return Column(
      children: [
        Expanded(
          child: FadeSlideTransition(
            delay: 0.1,
            child: Container(
              margin: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: 0,
              ),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.line),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CEFR 등급 퀴즈',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            quiz['korean_hint'] ?? '',
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // 즐겨찾기(북마크) 토글 버튼
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            provider.isCurrentBookmarked
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: provider.isCurrentBookmarked
                                ? const Color(0xFFFFC107)
                                : Colors.grey.shade400,
                            size: 32,
                          ),
                          onPressed: () => provider.toggleBookmark(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    if (provider.isWrong && provider.currentHint != null)
                      HintBox(hint: provider.currentHint!),

                    const SizedBox(height: 50),
                    _buildInputArea(provider, quiz['masked_sentence'] ?? ''),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildConfirmButton(provider),
      ],
    );
  }

  Widget _buildInputArea(GrammarProvider provider, String maskedSentence) {
    final parts = maskedSentence.split('____');
    final engBefore = parts.isNotEmpty ? parts[0] : '';
    final engAfter = parts.length > 1 ? parts[1] : '';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            engBefore,
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
        ),
        _buildTextField(provider),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(
            engAfter,
            style: const TextStyle(fontSize: 18, height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(GrammarProvider provider) {
    return Container(
      width: 120,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _answerController,
        onSubmitted: (_) => _handleAction(provider),
        textAlign: TextAlign.center,
        enabled: !provider.isChecking && provider.canRetry,
        style: TextStyle(
          fontSize: 20,
          color: provider.isWrong ? const Color(0xFFFF4757) : AppColors.primary,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: provider.isWrong
                  ? const Color(0xFFFF4757)
                  : Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: provider.isWrong
                  ? const Color(0xFFFF4757)
                  : AppColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(GrammarProvider provider) {
    String btnText = "확인";
    if (!provider.canRetry) {
      btnText = "다음 문제로 넘어가기";
    } else if (provider.currentCount == provider.totalCount) {
      btnText = "결과 보기";
    }

    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: provider.isChecking
                ? null
                : () => _handleAction(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: provider.isChecking
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    btnText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
