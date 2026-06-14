import 'package:flutter/material.dart';

import '../../../controllers/conversation_controller.dart';
import '../../../design/app_colors.dart';
import '../../../models/conversation_category_model.dart';
import '../../../routes/app_routes.dart';

class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  late Future<List<MainCategory>> _mainCategoriesFuture;
  Future<List<SubCategory>>? _subCategoriesFuture;
  MainCategory? _selectedCategory;
  SubCategory? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _mainCategoriesFuture = ConversationController.fetchMainCategories();
  }

  void _selectCategory(MainCategory category) {
    setState(() {
      _selectedCategory = category;
      _selectedSubCategory = null;
      _subCategoriesFuture = ConversationController.fetchSubCategories(
        category.mainCatId,
      );
    });
  }

  void _selectSubCategory(SubCategory subCategory) {
    setState(() => _selectedSubCategory = subCategory);
  }

  void _startConversation() {
    final selected = _selectedSubCategory;
    if (selected == null) return;
    Navigator.pushNamed(context, AppRoutes.conversation, arguments: selected);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          '실전회화 리스트',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        bottom: true,
        child: FutureBuilder<List<MainCategory>>(
          future: _mainCategoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  '회화 주제를 불러오지 못했습니다.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.primary),
                ),
              );
            }

            final categories = snapshot.data ?? [];
            if (categories.isEmpty) {
              return const Center(child: Text('사용 가능한 회화 주제가 없습니다.'));
            }

            final selectedCategory = _selectedCategory ?? categories.first;
            _subCategoriesFuture ??=
                ConversationController.fetchSubCategories(
                  selectedCategory.mainCatId,
                );

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 36),
                  child: Column(
                    children: [
                      _SelectionCard(
                        title: '회화 주제',
                        child: Column(
                          children: categories
                              .map(
                                (category) => _TopicLine(
                                  text: category.title,
                                  selected:
                                      category.mainCatId ==
                                      selectedCategory.mainCatId,
                                  onTap: () => _selectCategory(category),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 14),
                      FutureBuilder<List<SubCategory>>(
                        future: _subCategoriesFuture,
                        builder: (context, subSnapshot) {
                          if (subSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const _SelectionCard(
                              title: '상세 상황',
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 28),
                                child: CircularProgressIndicator(
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }
                          if (subSnapshot.hasError) {
                            return const _SelectionCard(
                              title: '상세 상황',
                              child: Text(
                                '상세 상황을 불러오지 못했습니다.',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            );
                          }

                          final subCategories = subSnapshot.data ?? [];
                          return _SelectionCard(
                            title: '상세 상황',
                            child: subCategories.isEmpty
                                ? const Text(
                                    '등록된 상세 상황이 없습니다.',
                                    style: TextStyle(color: Color(0xFF9B9B9B)),
                                  )
                                : Column(
                                    children: subCategories
                                        .map(
                                          (sub) => _TopicLine(
                                            text: sub.subTitle,
                                            selected:
                                                _selectedSubCategory
                                                    ?.subCatId ==
                                                sub.subCatId,
                                            onTap: () =>
                                                _selectSubCategory(sub),
                                          ),
                                        )
                                        .toList(),
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _selectedSubCategory == null
                              ? null
                              : _startConversation,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor: const Color(0xFFFFB3A8),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            '이대로 시작!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 4,
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
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _TopicLine extends StatelessWidget {
  const _TopicLine({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.primary : const Color(0xFF9B9B9B),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}
