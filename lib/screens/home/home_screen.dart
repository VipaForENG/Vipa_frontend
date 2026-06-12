import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/home_controller.dart';
import '../../models/home_summary_model.dart';

import '../ai/ai_screen.dart';
import '../conversation/category/category_selection_screen.dart';
import '../history/learning_history_screen.dart';
import '../mypage/mypage_screen.dart';
import '../vocabulary/vocabulary_dashboard_screen.dart';
import '../login/auth_widgets.dart';

import '../../../design/app_colors.dart';

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
      backgroundColor: AppColors.background,
      appBar: _selectedIndex == 0
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                '홈',
                style: TextStyle(
                  color: AuthColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.settings,
                    color: AuthColors.primary,
                    size: 25,
                  ),
                  onPressed: () => debugPrint("설정 클릭"),
                ),
              ],
            )
          : null,
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        currentIndex: _selectedIndex,
        selectedItemColor: AuthColors.primary,
        unselectedItemColor: const Color(0xFFD7D7D7),
        selectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_rounded),
            label: '학습내역',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_rounded),
            label: 'AI프리토킹',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: '마이페이지',
          ),
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
        return const Center(
          child: CircularProgressIndicator(color: AuthColors.primary),
        );
      }

      final data = controller.summary.value;
      if (data == null) {
        return const Center(child: Text('데이터가 없습니다.'));
      }

      return Container(
        color: AppColors.background,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(13, 20, 13, 24),
          child: Column(
            children: [
              _RankCard(data: data),
              const SizedBox(height: 14),
              _AttendanceCard(
                attendanceList: data.attendance,
                streakCount: data.continuousAttendanceCount,
              ),
              const SizedBox(height: 15),
              _HomeActionButton(
                color: AuthColors.primary,
                icon: Icons.menu_book_rounded,
                title: '오늘은 어떤 어휘를 배워볼까요?',
                subtitle: '오늘의 어휘 학습하기 >',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const VocabularyDashboardScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _HomeActionButton(
                color: const Color(0xFFFF806B),
                icon: Icons.people_alt_rounded,
                title: 'AI와 함께 실전에 통하는 회화!',
                subtitle: '실전회화 학습하기 >',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategorySelectionScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _RankCard extends StatelessWidget {
  const _RankCard({required this.data});

  final HomeSummary data;

  @override
  Widget build(BuildContext context) {
    final rank = VipaRank.fromTier(data.tier);
    final totalEnergy = data.weeklyData.fold<int>(
      0,
      (sum, item) => sum + item.totalEnergy,
    );
    final today = DateTime.now().toIso8601String().split('T').first;
    WeeklyData? todayData;
    for (final item in data.weeklyData) {
      if (item.date == today) {
        todayData = item;
        break;
      }
    }
    final todayVocabulary = todayData?.vocabEnergy ?? 0;
    final todayConversation = todayData?.convEnergy ?? 0;

    return _WhiteCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 23, 22, 19),
        child: Column(
          children: [
            RankBadge(rank: rank, size: 58),
            const SizedBox(height: 5),
            Text(
              rank.koreanName,
              style: TextStyle(
                color: rank.color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 19),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: (data.studyAchievementRate / 100)
                    .clamp(0.0, 1.0)
                    .toDouble(),
                minHeight: 6,
                backgroundColor: const Color(0xFFE5E5E5),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AuthColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _EnergyLine(label: '총 학습량', value: '$totalEnergy개'),
                  _EnergyLine(
                    label: '오늘의 어휘 학습량',
                    value: '$todayVocabulary개',
                    valueColor: AuthColors.primary,
                  ),
                  _EnergyLine(
                    label: '실전회화 학습량',
                    value: '$todayConversation개',
                    valueColor: AuthColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EnergyLine extends StatelessWidget {
  const _EnergyLine({
    required this.label,
    required this.value,
    this.valueColor = Colors.black,
  });

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: '$label : ',
        children: [
          TextSpan(
            text: value,
            style: TextStyle(color: valueColor, fontWeight: FontWeight.w900),
          ),
        ],
      ),
      style: const TextStyle(
        color: Colors.black,
        fontSize: 10,
        fontWeight: FontWeight.w800,
        height: 1.45,
      ),
    );
  }
}

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
    required this.attendanceList,
    required this.streakCount,
  });

  final List<String> attendanceList;
  final int streakCount;

  @override
  Widget build(BuildContext context) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];

    return _WhiteCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(43, 17, 43, 15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(days.length, (index) {
                final isDone = attendanceList.contains(days[index]);
                return _DayDot(
                  number: index + 1,
                  day: days[index],
                  isDone: isDone,
                );
              }),
            ),
            const SizedBox(height: 11),
            Text.rich(
              TextSpan(
                text: '연속출석 : ',
                children: [
                  TextSpan(
                    text: '$streakCount일!',
                    style: const TextStyle(color: AuthColors.primary),
                  ),
                ],
              ),
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.number,
    required this.day,
    required this.isDone,
  });

  final int number;
  final String day;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final dayColor = day == '토'
        ? Colors.blue
        : day == '일'
        ? AuthColors.primary
        : Colors.black;

    return Column(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDone ? AuthColors.primary : Colors.white,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: TextStyle(
              color: isDone ? Colors.white : Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: TextStyle(
            color: dayColor,
            fontSize: 8,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _HomeActionButton extends StatelessWidget {
  const _HomeActionButton({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 78,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: Colors.black.withValues(alpha: 0.28),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 28),
        ),
        child: Row(
          children: [
            Icon(icon, size: 37),
            const SizedBox(width: 22),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      height: 1.12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                  ),
                  const SizedBox(height: 7),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  const _WhiteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

enum VipaRank {
  bronze('브론즈', Color(0xFFC07A55)),
  silver('실버', Color(0xFFBFC0C0)),
  gold('골드', Color(0xFFFFA11A)),
  emerald('에메랄드', Color(0xFF28A8D7)),
  diamond('다이아', Color(0xFFE445B6)),
  master('마스터', Color(0xFF240028));

  const VipaRank(this.koreanName, this.color);

  final String koreanName;
  final Color color;

  static VipaRank fromTier(String tier) {
    switch (tier.toUpperCase()) {
      case 'SILVER':
        return VipaRank.silver;
      case 'GOLD':
        return VipaRank.gold;
      case 'EMERALD':
        return VipaRank.emerald;
      case 'DIAMOND':
        return VipaRank.diamond;
      case 'MASTER':
        return VipaRank.master;
      case 'BRONZE':
      default:
        return VipaRank.bronze;
    }
  }
}

class RankBadge extends StatelessWidget {
  const RankBadge({super.key, required this.rank, required this.size});

  final VipaRank rank;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RankBadgePainter(color: rank.color),
        child: Center(
          child: Text(
            '${rank.index + 1}',
            style: TextStyle(
              color: rank.color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              shadows: [const Shadow(color: Colors.white, blurRadius: 1)],
            ),
          ),
        ),
      ),
    );
  }
}

class _RankBadgePainter extends CustomPainter {
  const _RankBadgePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;
    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.35), 8, true);
    canvas.drawPath(path, Paint()..color = color);

    final inner = Path();
    final innerRadius = radius * 0.62;
    for (int i = 0; i < 6; i++) {
      final angle = -math.pi / 2 + i * math.pi / 3;
      final point = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      if (i == 0) {
        inner.moveTo(point.dx, point.dy);
      } else {
        inner.lineTo(point.dx, point.dy);
      }
    }
    inner.close();
    canvas.drawPath(inner, Paint()..color = Colors.white);
    canvas.drawPath(
      inner,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _RankBadgePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
