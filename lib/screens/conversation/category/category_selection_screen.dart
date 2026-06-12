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

  @override
  void initState() {
    super.initState();
    _mainCategoriesFuture = ConversationController.fetchMainCategories();
  }

  void _selectCategory(MainCategory category) {
    setState(() {
      _selectedCategory = category;
      _subCategoriesFuture = ConversationController.fetchSubCategories(
        category.mainCatId,
      );
    });
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
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<MainCategory>>(
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
                '주제를 불러오는 중 오류가 발생했습니다.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.primary),
              ),
            );
          }

          final categories = snapshot.data ?? [];
          if (categories.isEmpty) {
            return const Center(child: Text('사용 가능한 대화 주제가 없습니다.'));
          }

          final selected = _selectedCategory ?? categories.first;
          _subCategoriesFuture ??= ConversationController.fetchSubCategories(
            selected.mainCatId,
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
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
                                    category.mainCatId == selected.mainCatId,
                                onTap: () => _selectCategory(category),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<List<SubCategory>>(
                      future: _subCategoriesFuture,
                      builder: (context, subSnapshot) {
                        final subCategories = subSnapshot.data ?? [];
                        final loading =
                            subSnapshot.connectionState ==
                            ConnectionState.waiting;
                        final hasError = subSnapshot.hasError;

                        return _SelectionCard(
                          title: '상세 상황',
                          child: loading
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 28),
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                  ),
                                )
                              : hasError
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    '상세 상황을 불러오지 못했습니다.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                )
                              : subCategories.isEmpty
                              ? const Text(
                                  '등록된 시나리오가 없습니다.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF9B9B9B),
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )
                              : Column(
                                  children: subCategories
                                      .map(
                                        (sub) => _TopicLine(
                                          text: sub.subTitle,
                                          selected: sub == subCategories.first,
                                          onTap: () => Navigator.pushNamed(
                                            context,
                                            AppRoutes.conversation,
                                            arguments: sub,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final future = _subCategoriesFuture;
                          if (future == null) return;
                          final subs = await future;
                          if (!context.mounted || subs.isEmpty) {
                            return;
                          }
                          Navigator.pushNamed(
                            context,
                            AppRoutes.conversation,
                            arguments: subs.first,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: const Text(
                          '이대로 시작!',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 22),
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
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _TopicLine extends StatelessWidget {
  const _TopicLine({required this.text, required this.selected, this.onTap});

  final String text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: selected ? AppColors.primary : const Color(0xFF9B9B9B),
            fontSize: 18,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
      ),
    );
  }
}
