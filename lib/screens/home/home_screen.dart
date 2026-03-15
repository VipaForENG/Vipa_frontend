import 'package:flutter/material.dart';

// 1. 디자인 시스템 파일 임포트
import '../../design/card_design.dart';



// 기존 섹션 위젯들
import '../home/widgets/user_profile_section.dart';
import '../home/widgets/learning_chart_section.dart';
import '../home/widgets/attendance_section.dart';
import '../home/widgets/quick_menu_section.dart';

// 페이지별 임포트
import '../history/learning_history_screen.dart';
import '../ai/ai_screen.dart';
import '../mypage/mypage_screen.dart';

/// [클래스] HomeScreen
/// 목적: 앱의 메인 대시보드. 상태를 관리하여 하단 바 클릭 시 화면을 전환합니다.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // [변수] _selectedIndex: 현재 선택된 하단 바 인덱스
  int _selectedIndex = 0;

  // [리스트] _pages: 하단 바 클릭 시 보여줄 화면 목록 (이제 진짜 페이지 연결)
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _HomeContent(),          // 0번: 홈
      const LearningHistoryScreen(), // 1번: 학습내역
      const AiScreen(),              // 2번: AI 페이지
      const MyPageScreen(),          // 3번: 마이페이지
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 0 ? AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('홈', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
            onPressed: () => debugPrint("설정 버튼 클릭됨"),
          ),
        ],
      ) : null,

      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: '학습내역'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이페이지'),
        ],
      ),
    );
  }
}

/// [클래스] _HomeContent
/// 목적: 디자인 시스템(Card_Container 등)을 적용하여 홈 화면 본문 재구성
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Scaffold 배경이 흰색이므로, 약간의 회색톤을 주고 싶다면 여기서 조절 가능
      padding: const EdgeInsets.symmetric(vertical: 10), 
      child: Column(
        children: [
          // 2. 카드 컨테이너 적용 예시: 유저 프로필
          cardContainer(
            //height: 100, // 디자인에 맞춰 높이 조절
            child: const UserProfileSection(),
          ),

          // 3. 카드 컨테이너 적용 예시: 학습 차트
          cardContainer(
            //height: 250, 
            child: const LearningChartSection(),
          ),

          // 4. 출석부 섹션 (AttendanceSection 내부에 Circle_Container를 적용해야 함)
          cardContainer(
            height: 120,
            child: const AttendanceSection(),
          ),

          // 5. 퀵 메뉴 섹션 (이 안에서 buttonDesign을 사용하게 됨)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: QuickMenuSection(),
          ),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}