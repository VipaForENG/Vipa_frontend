import 'package:flutter/material.dart';

/// [클래스] GrammarScreen
/// 목적: 이미지 UI를 기반으로 한 '오늘의 어휘/문법' 학습 화면입니다.
class GrammarScreen extends StatefulWidget {
  const GrammarScreen({super.key});

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  // ==========================================================
  // [1. 상태 관리 변수]
  // ==========================================================
  int _currentCount = 0;       // 현재 맞춘 문제 수 (0/10의 분자)
  final int _totalCount = 10;  // 전체 목표 문제 수 (0/10의 분모)

  // 학습에 필요한 데이터셋 (나중에 서버 API와 연결하기 쉬운 구조)
  final Map<String, String> _quizData = {
    'level': '레벨 10',
    'category': '식당에서',
    'korean': '저희는 대부분의 손님들이 점심시간에 와요.',
    'hint': 'guest는 초청을 받아서 온 사람을 뜻합니다. 돈 내고 물건을 사는 사람은 뭐라고 부를까요?',
    'engBefore': 'We get most of our ',
    'engAfter': ' during lunchtime.',
    'answer': 'customers', // 실제 정답
  };

  // 사용자의 입력을 제어하는 컨트롤러
  final TextEditingController _answerController = TextEditingController();

  // ==========================================================
  // [2. 비즈니스 로직 함수]
  // ==========================================================
  
  /// [함수] _onCheckAnswer
  /// 목적: 사용자가 입력한 정답을 확인하고 상태를 업데이트합니다.
  void _onCheckAnswer() {
    String userInput = _answerController.text.trim().toLowerCase();
    
    // 정답 확인 로직
    if (userInput == _quizData['answer']) {
      setState(() {
        // 10문제 미만일 때만 카운트 증가
        if (_currentCount < _totalCount) _currentCount++;
      });
      
      // 입력창 초기화
      _answerController.clear();
      
      // 성공 피드백 (간단한 스낵바)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("정답입니다!"), duration: Duration(milliseconds: 500)),
      );
    } else {
      // 오답일 경우 처리
      debugPrint("오답입니다: $userInput");
    }
  }

  // ==========================================================
  // [3. 메인 빌드 함수]
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 전체 배경: 이미지와 동일한 연하늘색
      backgroundColor: const Color(0xFFD6EBFF),
      
      // [위젯] 앱바: 투명하게 설정하여 배경색이 투명하게 보이도록 함
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        title: _buildProgressBar(), // 커스텀 진행바 호출
        centerTitle: true,
        actions: const [
          Icon(Icons.settings, color: Colors.white),
          SizedBox(width: 15),
        ],
      ),
      
      body: Column(
        children: [
          const SizedBox(height: 20),
          
          // [위젯] 메인 학습 카드 (중앙 하얀 영역)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35), // 이미지처럼 많이 둥글게 설정
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderRow(), // 레벨 및 New 뱃지
                  const SizedBox(height: 10),
                  Text(_quizData['category']!, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 30),
                  
                  // 한국어 질문 문장
                  Text(
                    _quizData['korean']!,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, height: 1.4),
                  ),
                  const SizedBox(height: 25),

                  // 핑크색 힌트 박스 위젯 호출
                  _buildHintBox(),
                  
                  const Spacer(), // 위아래 간격을 균등하게 배분
                  
                  // 영어 문장 결합 영역 (텍스트 + 입력창 + 텍스트)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(_quizData['engBefore']!, style: const TextStyle(fontSize: 20)),
                      _buildAnswerInput(), // 정답 입력용 TextField
                      Text(_quizData['engAfter']!, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
          
          // [위젯] 하단 확인 버튼 영역
          _buildConfirmButton(),
        ],
      ),
    );
  }

  // ==========================================================
  // [4. 서브 UI 빌더 함수 (컴포넌트)]
  // ==========================================================

  /// [컴포넌트] 상단 커스텀 진행바 (0/10)
  Widget _buildProgressBar() {
    return Container(
      width: 160,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5), // 반투명 배경
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 오렌지색 게이지 (진행도에 따라 너비가 변함)
          FractionallySizedBox(
            widthFactor: _currentCount / _totalCount, // 0.0 ~ 1.0 사이 값
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orangeAccent,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // 게이지 위에 표시될 숫자 텍스트
          Center(
            child: Text(
              "$_currentCount/$_totalCount",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// [컴포넌트] 레벨 정보 및 'New' 아이콘 행
  Widget _buildHeaderRow() {
    return Row(
      children: [
        Text(_quizData['level']!, style: const TextStyle(color: Color(0xFF64B5F6), fontWeight: FontWeight.bold)),
        const SizedBox(width: 5),
        const Icon(Icons.help_outline, size: 16, color: Color(0xFF64B5F6)),
        const Spacer(),
        // 빨간색 'New' 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
          child: const Text("New", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
        )
      ],
    );
  }

  /// [컴포넌트] 연핑크색 힌트 박스 영역
  Widget _buildHintBox() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFECEF), // 연핑크 배경
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: Colors.redAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _quizData['hint']!,
              style: const TextStyle(color: Color(0xFFFF7088), fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// [컴포넌트] 정답 입력용 TextField (문장 사이에 위치)
  Widget _buildAnswerInput() {
    return Container(
      width: 100, // 입력창 너비 고정
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: TextField(
        controller: _answerController,
        textAlign: TextAlign.center, // 텍스트 중앙 정렬
        autofocus: true, // 화면 진입 시 바로 키보드 활성화
        style: const TextStyle(fontSize: 20, color: Colors.blueAccent, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.zero,
          // 하단 파란색 강조선
          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent, width: 2)),
          focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent, width: 3)),
        ),
      ),
    );
  }

  /// [컴포넌트] 하단 보라색 확인 버튼
  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity, // 가로 전체 너비
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      child: ElevatedButton(
        onPressed: _onCheckAnswer, // 클릭 시 정답 체크 함수 호출
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF7B61FF), // 보라색 버튼
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("확인", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}