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
      // 🌟 수정: GrammarProvider로 타입 변경!
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
    // 🌟 수정: GrammarProvider로 타입 변경!
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

  // 🌟 수정: GrammarProvider로 타입 변경!
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
                    Text(quiz['korean_hint'] ?? '', style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
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

  // 🌟 수정: GrammarProvider로 타입 변경!
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

  // 🌟 수정: GrammarProvider로 타입 변경!
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


 void _handleCheck(GrammarProvider provider) {
    provider.checkAnswer(
      _answerController.text,
      () {
        // [정답 콜백] 텍스트 필드를 비우고 Vipa 커스텀 스낵바 노출
        _answerController.clear();
        VipaSnackBar.show(context, "정답입니다! 다음 문제로 갑니다! 🎉");
      },
      () {
        // ✨ [종료 콜백] 마지막 문제까지 모두 통과하여 submitSession 완료 시 호출됨
        _answerController.clear();
        
        // 프로바이더가 백엔드 서버로부터 가로채 보관 중인 일괄 채점 리포트를 Arguments로 바인딩
        Get.offNamed(
          AppRoutes.vocabularyResult, 
          arguments: provider.completionResult ?? {
            'total_count': provider.totalCount,
            'correct_count': provider.totalCount, // 폴백용 방어 데이터 세팅
            'score_percentage': 100.0,
            'results': []
          }
        );
      }
    );
  }

  // 🌟 수정: GrammarProvider로 타입 변경!
  Widget _buildConfirmButton(GrammarProvider provider) {
    return SafeArea( 
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), 
        color: Colors.transparent, 
        child: SizedBox(
          height: 56, 
          child: ElevatedButton(
            onPressed: provider.isChecking ? null : () => _handleCheck(provider),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B61FF),
              disabledBackgroundColor: Colors.grey.shade300, 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
            ),
            child: provider.isChecking 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text(provider.currentCount == provider.totalCount ? "결과 보기" : "확인", style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}