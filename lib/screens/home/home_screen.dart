import 'package:flutter/material.dart';
// 기존 위젯들 (절대 경로 주의)
import '../home/widgets/user_profile_section.dart';
import '../home/widgets/learning_chart_section.dart';
import '../home/widgets/attendance_section.dart';
import '../home/widgets/quick_menu_section.dart';
// 페이지별 임포트 (경로 확실히 잡았음)
import '../history/learning_history_screen.dart';
import '../ai/ai_screen.dart';          // AI 페이지 추가
import '../mypage/mypage_screen.dart';  // 마이페이지 추가

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
            onPressed: () => print("설정 버튼 클릭됨"),
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
/// 목적: 홈 화면의 본문 콘텐츠를 분리하여 가독성을 높임
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: const [
          UserProfileSection(),
          SizedBox(height: 24),
          LearningChartSection(),
          SizedBox(height: 24),
          AttendanceSection(),
          SizedBox(height: 24),
          QuickMenuSection(),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}