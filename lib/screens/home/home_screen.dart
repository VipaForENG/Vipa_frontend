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

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.summary.value == null) {
        return const Center(child: Text("데이터가 없습니다."));
      }

      final data = controller.summary.value!;

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            cardContainer(
              child: UserProfileSection(
                nickname: data.nickname,
                tier: data.tier,
                topPercent: data.topPercent,
              ),
            ),
            cardContainer(
              child: LearningChartSection(weeklyData: data.weeklyData),
            ),
            cardContainer(
              height: 120,
              child: AttendanceSection(
                attendanceList: controller.summary.value!.attendance,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: QuickMenuSection(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }
}