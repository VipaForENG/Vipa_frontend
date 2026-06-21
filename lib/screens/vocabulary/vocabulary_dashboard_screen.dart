import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';
import 'vocabulary_dashboard_provider.dart';

// ✨ 디자인 시스템 (배경 및 색상 유지)
import '../../design/background.dart';
import '../../design/app_colors.dart';

class VocabularyDashboardScreen extends StatefulWidget {
  const VocabularyDashboardScreen({super.key});

  @override
  State<VocabularyDashboardScreen> createState() =>
      _VocabularyDashboardScreenState();
}

class _VocabularyDashboardScreenState extends State<VocabularyDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VocabularyDashboardProvider>(
        context,
        listen: false,
      ).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VocabularyDashboardProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '오늘의 어휘는?',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Background(
              fillLevel: 0.25,
              child: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 430),
                    child: Column(
                      children: [
                        const SizedBox(height: 22),
                        // 애니메이션 없이 즉시 표시
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _GoalSliderCard(
                                title: '새로운 단어는 몇개를 배워볼까요?',
                                value: provider.chosenNew,
                                onChanged: (value) =>
                                    provider.setCount('new', value),
                              ),
                              const SizedBox(height: 12),
                              _GoalSliderCard(
                                title: '복습할 단어는 얼마나 할까요?',
                                value: provider.chosenReview,
                                onChanged: (value) =>
                                    provider.setCount('review', value),
                              ),
                              const SizedBox(height: 12),
                              _GoalSliderCard(
                                title: '재도전 단어는 몇개나 할까요?',
                                value: provider.chosenRetry,
                                onChanged: (value) =>
                                    provider.setCount('retry', value),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 52,
                            vertical: 0,
                          ),
                          child: AuthButton(
                            text: '이대로 시작!',
                            onPressed: () {
                              if (provider.chosenNew == 0 &&
                                  provider.chosenReview == 0 &&
                                  provider.chosenRetry == 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('학습할 단어를 1개 이상 선택해주세요!'),
                                  ),
                                );
                                return;
                              }

                              Navigator.pushNamed(
                                context,
                                AppRoutes.vocabulary,
                                arguments: {
                                  'new_count': provider.chosenNew,
                                  'review_count': provider.chosenReview,
                                  'retry_count': provider.chosenRetry,
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

// ✨ 기존 PageView 기반 슬라이더 카드 (100% 유지)
class _GoalSliderCard extends StatefulWidget {
  const _GoalSliderCard({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_GoalSliderCard> createState() => _GoalSliderCardState();
}

class _GoalSliderCardState extends State<_GoalSliderCard> {
  late PageController _controller;

  int get _pageCount => VocabularyDashboardProvider.maxGoalWords + 1;
  int get _currentValue =>
      widget.value.clamp(0, VocabularyDashboardProvider.maxGoalWords).toInt();

  @override
  void initState() {
    super.initState();
    final initialPage = _currentValue;
    _controller = PageController(
      initialPage: initialPage,
      viewportFraction: 0.14,
    );
  }

  @override
  void didUpdateWidget(covariant _GoalSliderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetPage = _currentValue
        .clamp(0, _pageCount - 1)
        .toInt();
    if (_controller.hasClients && targetPage != _controller.page?.round()) {
      _controller.jumpToPage(targetPage);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 31,
            child: PageView.builder(
              controller: _controller,
              itemCount: _pageCount,
              onPageChanged: (index) => widget.onChanged(index),
              itemBuilder: (context, index) {
                final number = index;
                final selected = number == _currentValue;
                return Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: selected
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.55),
                      fontSize: selected ? 26 : 14,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
