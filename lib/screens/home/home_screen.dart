import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../design/card_design.dart';
import '../../../controllers/home_controller.dart';
import 'widgets/user_profile_section.dart';
import 'widgets/learning_chart_section.dart';
import 'widgets/attendance_section.dart';
import 'widgets/quick_menu_section.dart';
import '../history/learning_history_screen.dart';
import '../ai/ai_screen.dart';
import '../mypage/mypage_screen.dart';
import '../../../design/animation_design.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const _HomeContent(),
      const LearningHistoryScreen(),
      const AiScreen(),
      const MyPageScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5E4AD),
      appBar: _selectedIndex == 0 ? AppBar(
        backgroundColor: Color(0xFFF5E4AD),
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

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());
    // 로그인 화면과 유사한 배경색 설정 (필요에 따라 변경)
    const Color waveColor = Color(0xFFFFF9E3);
    const Color bgColor = Color(0xFFF5E4AD);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.summary.value == null) {
        return const Center(child: Text("데이터가 없습니다."));
      }

      final data = controller.summary.value!;

      // 1. Stack을 사용하여 배경과 콘텐츠 분리
      return Container(
        color: bgColor, // 전체 배경색 지정 (Scaffold가 투명해야 보임)
        child: Stack(
          children: [
            // 2. 파도 배경 (홈 화면이므로 waveHeightFactor는 고정값 사용)
            Positioned.fill(
              child: const WaveBackground(waveColor: waveColor, waveHeightFactor: 0.35),
            ),
            
            // 3. 기존 콘텐츠 (SingleChildScrollView)
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    // 4. FadeSlideTransition 적용 (delay 조절)
                    FadeSlideTransition(
                      delay: 0.1,
                      child: cardContainer(
                        child: UserProfileSection(
                          nickname: data.nickname,
                          tier: data.tier,
                          topPercent: data.topPercent,
                          studyAchievementRate: data.studyAchievementRate,
                        ),
                      ),
                    ),
                    FadeSlideTransition(
                      delay: 0.3,
                      child: cardContainer(
                        child: LearningChartSection(weeklyData: data.weeklyData),
                      ),
                    ),
                    FadeSlideTransition(
                      delay: 0.5,
                      child: cardContainer(
                        // 🔥 [수정] height: 155 삭제. 자식 위젯의 크기에 맞춰 자동으로 늘어나게 함.
                        child: AttendanceSection(
                          attendanceList: controller.summary.value!.attendance,
                          streakCount: controller.summary.value!.continuousAttendanceCount,
                        ),
                      ),
                    ),
                    const FadeSlideTransition(
                      delay: 0.7,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: QuickMenuSection(),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}