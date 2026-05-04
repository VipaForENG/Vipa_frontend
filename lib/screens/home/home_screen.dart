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
import '../robot/robot_setup_screen.dart';

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
      backgroundColor: const Color(0xFFF5E4AD),
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: const Color(0xFFF5E4AD),
              elevation: 0,
              title: const Text('홈',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.smart_toy_outlined, color: Colors.black),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RobotSetupScreen())),
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined, color: Colors.black),
                  onPressed: () => debugPrint("설정 클릭"),
                ),
              ],
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _selectedIndex = index),
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

class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<_HomeContent> with SingleTickerProviderStateMixin {
  late AnimationController _waveUpController;
  late Animation<double> _heightAnimation;
  
  // 🎯 [수정] Get.put을 사용하여 컨트롤러를 확실히 주입합니다.
  final HomeController controller = Get.put(HomeController());

  @override
  void initState() {
    super.initState();

    // 1. 물결 상승 애니메이션 설정 (1.5초 동안 확 올라가는 연출)
    _waveUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 2. 0.0(바닥) -> 1.1(화면 상단을 살짝 덮음)까지 상승
    _heightAnimation = Tween<double>(begin: 0.0, end: 1.1).animate(
      CurvedAnimation(parent: _waveUpController, curve: Curves.easeOutQuart),
    );

    // 3. 로딩이 끝나면 애니메이션 시작하도록 리스너 등록
    ever(controller.isLoading, (bool isLoading) {
      if (!isLoading && mounted) {
        _startAnimation();
      }
    });

    // 만약 이미 데이터가 있는 경우 즉시 실행
    if (!controller.isLoading.value && controller.summary.value != null) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    Future.microtask(() {
      if (mounted) {
        _waveUpController.reset(); // 0부터 다시 시작 보장
        _waveUpController.forward();
      }
    });
  }

  @override
  void dispose() {
    _waveUpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color waveColor = Color(0xFFFFF9E3);

    return Obx(() {
      // 로딩 중일 때 표시
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final data = controller.summary.value;
      if (data == null) return const Center(child: Text("데이터가 없습니다."));

      return AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, child) {
          return Container(
            // 물결이 다 차오르면 배경색을 물결색과 맞춤
            color: _heightAnimation.value > 0.95 ? waveColor : const Color(0xFFF5E4AD),
            child: Stack(
              children: [
                // 🌊 아래에서 위로 차오르는 물결
                Positioned.fill(
                  child: WaveBackground(
                    waveColor: waveColor,
                    waveHeightFactor: _heightAnimation.value,
                  ),
                ),

                // 📄 물결 뒤에 나타나는 카드들
                Positioned.fill(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        FadeSlideTransition(
                          delay: 0.4,
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
                          delay: 0.6,
                          child: cardContainer(
                            child: LearningChartSection(weeklyData: data.weeklyData),
                          ),
                        ),
                        FadeSlideTransition(
                          delay: 0.8,
                          child: cardContainer(
                            child: AttendanceSection(
                              attendanceList: data.attendance,
                              streakCount: data.continuousAttendanceCount,
                            ),
                          ),
                        ),
                        const FadeSlideTransition(
                          delay: 1.0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                            child: QuickMenuSection(),
                          ),
                        ),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}