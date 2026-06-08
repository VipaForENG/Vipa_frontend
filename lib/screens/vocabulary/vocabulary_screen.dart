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
  bool _showHint = false;
  Object? _visibleQuizId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 전달받은 퀴즈 설정 로직
      final args = Get.arguments ?? {'new_count': 5, 'review_count': 10, 'retry_count': 10};
      
      Provider.of<GrammarProvider>(context, listen: false).fetchQuiz(
        args['new_count'], 
        args['review_count'], 
        args['retry_count']
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
    final quiz = provider.currentQuiz;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GrammarProgressBar(
          current: provider.currentCount,
          total: provider.totalCount,
        ),
        centerTitle: true,
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
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
      _showHint = false;
    }

    return Column(
      children: [
        Expanded(
          child: FadeSlideTransition(
            delay: 0.1,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CEFR 등급 퀴즈', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    Text(
                      quiz['korean_hint'] ?? '',
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 25),

                    // 틀렸을 때 나타나는 힌트 박스
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

  // 텍스트 필드와 문장을 결합하는 UI
  Widget _buildInputArea(GrammarProvider provider, String maskedSentence) {
    final parts = maskedSentence.split('____');
    final engBefore = parts.isNotEmpty ? parts[0] : '';
    final engAfter = parts.length > 1 ? parts[1] : '';

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(engBefore, style: const TextStyle(fontSize: 18, height: 1.5)),
        ),
        _buildTextField(provider),
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(engAfter, style: const TextStyle(fontSize: 18, height: 1.5)),
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
        onSubmitted: (_) => _handleCheck(provider),
        textAlign: TextAlign.center,
        enabled: !provider.isChecking,
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
              color: provider.isWrong ? const Color(0xFFFF4757) : Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: provider.isWrong ? const Color(0xFFFF4757) : AppColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  // 제출/다음 버튼 로직
  Widget _buildConfirmButton(GrammarProvider provider) {
    return SafeArea(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: provider.isChecking ? null : () => _handleCheck(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: provider.isChecking
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                : Text(
                    provider.currentCount == provider.totalCount ? "결과 보기" : "확인",
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ),
    );
  }

  void _handleCheck(GrammarProvider provider) {
    provider.checkAnswer(
      _answerController.text,
      () {
        // 정답 처리
        _answerController.clear();
        setState(() => _showHint = false);
        VipaSnackBar.show(context, '정답입니다! 다음 문제로 갑니다!');
      },
      () {
        // 퀴즈 종료 (결과 화면 이동)
        _answerController.clear();
        Get.offNamed(
          AppRoutes.vocabularyResult,
          arguments: provider.completionResult ?? {
            'total_count': provider.totalCount,
            'correct_count': provider.totalCount,
            'results': [],
          },
        );
      },
      () {
        // 오답/기회 소진 처리
        VipaSnackBar.show(context, '기회를 모두 소진했습니다. 정답을 확인하세요!');
        _answerController.text = provider.targetWord ?? '';
        setState(() => _showHint = true);
      },
    );
  }
}