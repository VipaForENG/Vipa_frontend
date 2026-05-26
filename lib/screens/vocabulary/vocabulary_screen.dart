import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 
import 'package:get/get.dart';

// [도메인 임포트] 파일명 확인 필수! (vocabulary_provider.dart 내부에 GrammarProvider 클래스가 있음)
import 'vocabulary_provider.dart'; 
import 'widgets/vocabulary_widgets.dart'; 

// ✨ [디자인 시스템 임포트] 
import '../../design/snack_bar.dart'; 
import '../../design/background.dart'; 
import '../../design/animation_design.dart'; 
import '../../routes/app_routes.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
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

    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.white, 
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: GrammarProgressBar(current: provider.currentCount, total: provider.totalCount),
        centerTitle: true,
      ),
      
      body: provider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Background(
              fillLevel: 0.25, 
              child: SafeArea(
                bottom: false, 
                child: _buildQuizBody(provider),
              ),
            ),
    );
  }

  Widget _buildQuizBody(GrammarProvider provider) {
    final quiz = provider.currentQuiz;
    if (quiz == null) return const SizedBox.shrink();

    return Column(
      children: [
        Expanded(
          child: FadeSlideTransition(
            delay: 0.1, 
            child: Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 0),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))
                ]
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('CEFR 등급 퀴즈', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    
                    // 🌟 수정: 한국어 힌트 텍스트와 즐겨찾기 아이콘을 Row로 묶어서 나란히 배치
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            quiz['korean_hint'] ?? '', 
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)
                          ),
                        ),
                        // ✨ [신규 추가] 즐겨찾기(북마크) 토글 버튼
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            provider.isCurrentBookmarked ? Icons.star_rounded : Icons.star_border_rounded,
                            color: provider.isCurrentBookmarked ? const Color(0xFFFFC107) : Colors.grey.shade400,
                            size: 32,
                          ),
                          onPressed: () {
                            provider.toggleBookmark();
                          },
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

  // 🌟 수정: 텍스트 필드 제어 (기회가 없으면 입력 불가)
  Widget _buildTextField(GrammarProvider provider) {
    return Container(
      width: 120, 
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: TextField(
        controller: _answerController,
        onSubmitted: (_) => _handleAction(provider),
        textAlign: TextAlign.center,
        // 기회가 없으면 텍스트 필드 잠금
        enabled: !provider.isChecking && provider.canRetry,
        style: TextStyle(
          fontSize: 20, 
          color: provider.isWrong ? const Color(0xFFFF4757) : const Color(0xFF7B61FF),
          fontWeight: FontWeight.bold
        ),
        decoration: InputDecoration(
          isDense: true, 
          contentPadding: const EdgeInsets.symmetric(vertical: 4), 
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: provider.isWrong ? const Color(0xFFFF4757) : Colors.grey.shade400, width: 2)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: provider.isWrong ? const Color(0xFFFF4757) : const Color(0xFF7B61FF), width: 2)),
        ),
      ),
    );
  }

  // 🌟 수정: 제출 및 다음으로 넘어가기 통합 핸들러
  void _handleAction(GrammarProvider provider) {
    // 1. 이미 기회를 다 쓴 상태에서 버튼을 눌렀다면 -> 정답 제출하지 않고 바로 다음 문제로 패스!
    if (!provider.canRetry) {
      _answerController.clear();
      provider.forceNextQuestion(
        () {}, // 화면만 전환되므로 별도 스낵바 불필요
        () => _finishQuiz(provider)
      );
      return;
    }

    // 2. 정상적인 답안 제출 로직
    provider.checkAnswer(
      _answerController.text,
      () {
        // [정답 콜백] 
        _answerController.clear();
        VipaSnackBar.show(context, "정답입니다! 다음 문제로 갑니다! 🎉");
      },
      () {
        // [종료 콜백]
        _finishQuiz(provider);
      },
      () {
        // ✨ [신규 추가] 2회 오답으로 기회 소진 콜백
        VipaSnackBar.show(context, "기회를 모두 소진했습니다. 정답을 확인하세요!");
        // 텍스트 필드에 진짜 정답을 채워넣어 보여줌
        _answerController.text = provider.targetWord ?? "알 수 없음"; 
      }
    );
  }

  // 중복 코드 분리용
  void _finishQuiz(GrammarProvider provider) {
    _answerController.clear();
    Get.offNamed(
      AppRoutes.vocabularyResult, 
      arguments: provider.completionResult ?? {
        'total_count': provider.totalCount,
        'correct_count': provider.totalCount, 
        'score_percentage': 100.0,
        'results': []
      }
    );
  }

  // 🌟 수정: 버튼 라벨 동적 변경
  Widget _buildConfirmButton(GrammarProvider provider) {
    // 상황에 맞는 버튼 텍스트 설정
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
        color: Colors.transparent, 
        child: SizedBox(
          height: 56, 
          child: ElevatedButton(
            onPressed: provider.isChecking ? null : () => _handleAction(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B61FF),
              disabledBackgroundColor: Colors.grey.shade300, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
            ),
            child: provider.isChecking 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text(btnText, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}