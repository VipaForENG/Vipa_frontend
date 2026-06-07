import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';
import 'vocabulary_dashboard_provider.dart';

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
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AuthColors.primary),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                    child: Column(
                      children: [
                        const Text(
                          '오늘의 어휘 목표량',
                          style: TextStyle(
                            color: AuthColors.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 34),
                        _GoalSliderCard(
                          title: '새로운 단어는 몇개를 배워볼까요?',
                          value: provider.chosenNew,
                          onChanged: (value) => provider.setCount('new', value),
                        ),
                        const SizedBox(height: 15),
                        _GoalSliderCard(
                          title: '복습할 단어는 얼마나 할까요?',
                          value: provider.chosenReview,
                          onChanged: (value) =>
                              provider.setCount('review', value),
                        ),
                        const SizedBox(height: 15),
                        _GoalSliderCard(
                          title: '재도전 단어는 몇개나 할까요?',
                          value: provider.chosenRetry,
                          onChanged: (value) =>
                              provider.setCount('retry', value),
                        ),
                        const SizedBox(height: 25),
                        AuthButton(
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
                        const Spacer(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

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

  int get _pageCount => VocabularyDashboardProvider.maxGoalWords;
  int get _currentValue => widget.value.clamp(0, _pageCount).toInt();

  @override
  void initState() {
    super.initState();
    final initialPage = (_currentValue <= 0 ? 1 : _currentValue) - 1;
    _controller = PageController(
      initialPage: initialPage,
      viewportFraction: 0.14,
    );
  }

  @override
  void didUpdateWidget(covariant _GoalSliderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final targetPage = ((_currentValue <= 0 ? 1 : _currentValue) - 1)
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
      padding: const EdgeInsets.fromLTRB(18, 25, 18, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 5,
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
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 36,
            child: PageView.builder(
              controller: _controller,
              itemCount: _pageCount,
              onPageChanged: (index) => widget.onChanged(index + 1),
              itemBuilder: (context, index) {
                final number = index + 1;
                final selected = number == _currentValue;
                return Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: selected
                          ? AuthColors.primary
                          : AuthColors.primary.withValues(alpha: 0.45),
                      fontSize: selected ? 25 : 12,
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
