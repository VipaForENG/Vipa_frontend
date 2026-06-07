import 'package:flutter/material.dart';

import '../../../controllers/conversation_controller.dart';
import '../../../models/conversation_category_model.dart';
import '../../../routes/app_routes.dart';
import '../../login/auth_widgets.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late Future<_ConversationListData> _future;
  int _selectedMainIndex = 0;
  int _selectedSubIndex = 0;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_ConversationListData> _loadData() async {
    final mainCategories = await ConversationController.fetchMainCategories();
    final Map<int, List<SubCategory>> subCategories = {};

    for (final main in mainCategories) {
      subCategories[main.mainCatId] =
          await ConversationController.fetchSubCategories(main.mainCatId);
    }

    return _ConversationListData(
      mainCategories: mainCategories,
      subCategories: subCategories,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: FutureBuilder<_ConversationListData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AuthColors.primary),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '데이터를 불러오지 못했습니다.\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AuthColors.primary),
                    ),
                  );
                }

                final data = snapshot.data;
                if (data == null || data.mainCategories.isEmpty) {
                  return const Center(child: Text('등록된 실전회화가 없습니다.'));
                }

                final mainCategories = data.mainCategories;
                final selectedMainIndex =
                    _selectedMainIndex.clamp(0, mainCategories.length - 1).toInt();
                final selectedMain = mainCategories[selectedMainIndex];
                final subs = data.subCategories[selectedMain.mainCatId] ?? [];
                final selectedSubIndex = subs.isEmpty
                    ? 0
                    : _selectedSubIndex.clamp(0, subs.length - 1).toInt();
                final selectedSub =
                    subs.isEmpty ? null : subs[selectedSubIndex];

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                  child: Column(
                    children: [
                      const Text(
                        '실전회화 리스트',
                        style: TextStyle(
                          color: AuthColors.primary,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 34),
                      _ListCard(
                        title: '회화 주제',
                        child: Column(
                          children: List.generate(mainCategories.length, (index) {
                            final category = mainCategories[index];
                            return _SelectableTextLine(
                              text: category.title,
                              isSelected: index == _selectedMainIndex,
                              onTap: () {
                                setState(() {
                                  _selectedMainIndex = index;
                                  _selectedSubIndex = 0;
                                });
                              },
                            );
                          }),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _ListCard(
                        title: '상세 상황',
                        child: subs.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 22),
                                child: Text(
                                  '등록된 상세 상황이 없습니다.',
                                  style: TextStyle(
                                    color: Colors.black38,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              )
                            : Column(
                                children: List.generate(subs.length, (index) {
                                  final sub = subs[index];
                                  return _SelectableTextLine(
                                    text: sub.subTitle,
                                    isSelected: index == _selectedSubIndex,
                                    onTap: () {
                                      setState(() => _selectedSubIndex = index);
                                    },
                                  );
                                }),
                              ),
                      ),
                      const SizedBox(height: 22),
                      AuthButton(
                        text: '이대로 시작!',
                        onPressed: selectedSub == null
                            ? null
                            : () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.conversation,
                                  arguments: selectedSub,
                                ),
                      ),
                      const Spacer(),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ConversationListData {
  const _ConversationListData({
    required this.mainCategories,
    required this.subCategories,
  });

  final List<MainCategory> mainCategories;
  final Map<int, List<SubCategory>> subCategories;
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 21, 18, 23),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.22),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _SelectableTextLine extends StatelessWidget {
  const _SelectableTextLine({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? AuthColors.primary : const Color(0xFF9B9B9B),
            fontSize: 18,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            height: 1.12,
          ),
        ),
      ),
    );
  }
}
