import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../Design/snack_bar.dart';
import '../../controllers/level_test_controller.dart';
// 1. 우리가 만든 공통 배경 위젯을 임포트합니다.
import '../../design/background.dart';

class LevelTestScreen extends StatefulWidget {
  const LevelTestScreen({super.key});

  @override
  State<LevelTestScreen> createState() => _LevelTestScreenState();
}

class _LevelTestScreenState extends State<LevelTestScreen> {
  List<dynamic> _questions = [];           // 서버에서 받아온 전체 문제 리스트
  final List<String> _userAnswers = [];    // 사용자가 입력한 답변 저장 리스트
  int _currentIndex = 0;                   // 현재 풀고 있는 문제 번호 인덱스
  bool _isLoading = true;                  // 로딩 상태 제어 (데이터 로드/제출 중)
  final TextEditingController _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchQuestions(); // 화면 진입 시 문제 로드
  }

  /// [Vipa Logic] 1. 서버로부터 레벨 테스트 문제 로드
  Future<void> _fetchQuestions() async {
    final questions = await LevelTestController.getLevelTestQuestions();

    if (questions != null) {
      if (mounted) {
        setState(() {
          // 백엔드 부하를 줄이기 위해 최대 20문제까지만 가져오도록 제한합니다.
          _questions = questions.take(20).toList();
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        VipaSnackBar.show(context, '문제를 불러오지 못했습니다.');
      }
    }
  }

  /// [Vipa Logic] 2. 결과 제출 및 홈 화면 이동
  Future<void> _submitResults() async {
    setState(() => _isLoading = true);
    final bool success = await LevelTestController.submitLevelTest(_userAnswers);

    if (success) {
      if (!mounted) return;
      VipaSnackBar.show(context, '테스트가 완료되었습니다!');
      // 테스트 완료 후 스택을 비우고 홈 화면으로 이동 (뒤로가기 방지)
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        VipaSnackBar.show(context, '제출 중 오류가 발생했습니다.');
      }
    }
  }

  /// [Vipa Logic] 3. '다음' 버튼 클릭 시 유효성 검사 및 인덱스 이동
  void _onNextPressed() {
    final answer = _answerController.text.trim();
    
    // 답변이 비어있을 경우 스낵바 알림 후 중단
    if (answer.isEmpty) {
      VipaSnackBar.show(context, '답변을 입력해주세요.');
      return;
    }

    _userAnswers.add(answer); // 답변 리스트에 추가
    _answerController.clear(); // 입력창 초기화

    // 마지막 문제가 아니면 다음 문제로, 마지막이면 결과 제출
    if (_currentIndex < _questions.length - 1) {
      setState(() => _currentIndex++);
    } else {
      _submitResults();
    }
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때 표시할 화면 (로딩 위젯에도 배경을 줄 수 있지만, 깔끔하게 Center 유지)
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.black87)),
      );
    }

    // [데이터 파싱] 서버 응답이 String 배열일 수도 있고 Map 배열일 수도 있으므로 방어 코드를 작성합니다.
    final dynamic currentData = _questions[_currentIndex];
    String displayQuestion = "";

    if (currentData is String) {
      displayQuestion = currentData;
    } else if (currentData is Map) {
      // 서버 gpt5.py의 응답 키값에 따라 question 혹은 text를 추출합니다.
      displayQuestion = currentData['question'] ?? currentData['text'] ?? "문제를 표시할 수 없습니다.";
    }

    return Scaffold(
      // 배경이 상단 상태바까지 확장되도록 설정
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text(
          'CEFR 레벨 테스트',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // 배경 애니메이션이 보이도록 투명 설정
        elevation: 0,
        automaticallyImplyLeading: false, // 테스트 중 이탈 방지를 위해 뒤로가기 제거
      ),
      // 🌊 [UI Point] 공통 배경 위젯 적용 (파고 0.2로 설정하여 상단에 위치)
      body: Background(
        fillLevel: 0.2, 
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // --- 문제 카드 영역 ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    // 배경 물결이 은은하게 비치도록 투명도(0.9) 적용
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 문항 번호 라벨
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Q${_currentIndex + 1}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // 질문 텍스트
                      Center(
                        child: Text(
                          displayQuestion,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 1.4, // 가독성을 위한 줄간격 조절
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // 답변 입력창
                      TextField(
                        controller: _answerController,
                        autofocus: true, // 화면 시작 시 바로 키보드 활성화
                        style: const TextStyle(fontSize: 18),
                        decoration: const InputDecoration(
                          hintText: 'Answer in English...',
                          hintStyle: TextStyle(color: Colors.grey),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black, width: 2),
                          ),
                        ),
                        onSubmitted: (_) => _onNextPressed(), // 키보드 '완료' 버튼 대응
                      ),
                      const SizedBox(height: 20),
                      // 현재 진행 상태 (예: 1 / 20)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_currentIndex + 1} / ${_questions.length}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(), // 카드와 버튼 사이 공간 확보
                // --- 하단 다음/제출 버튼 ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _onNextPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        _currentIndex < _questions.length - 1 ? 'Next Question' : 'Submit Test',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}