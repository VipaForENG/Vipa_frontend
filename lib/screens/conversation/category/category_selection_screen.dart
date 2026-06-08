import 'package:flutter/material.dart';

// API 컨트롤러, 데이터 모델, 라우팅 컨벤션 및 디자인 시스템 의존성 매핑
import '../../../controllers/conversation_controller.dart';
import '../../../models/conversation_category_model.dart';
import '../../../routes/app_routes.dart';
import '../../../design/app_colors.dart';

/// [카테고리 선택 메인 화면]
/// 작성하신 커스텀 리스트 UI 디자인을 사용하며, 
/// 라우팅 및 데이터 로드는 팀원의 L3 분리 아키텍처 흐름을 따릅니다.
class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() => _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  /// [성능 최적화] 위젯 빌드 시 API 중복 호출을 막기 위한 Future 캐싱 변수
  late Future<List<MainCategory>> _mainCategoriesFuture;

  @override
  void initState() {
    super.initState();
    // initState 시점에 딱 한 번만 API를 호출하여 메모리 누수와 불필요한 트래픽을 방지합니다.
    _mainCategoriesFuture = ConversationController.fetchMainCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Vipa 디자인 시스템 배경색
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          '학습 주제 선택',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<List<MainCategory>>(
        future: _mainCategoriesFuture,
        builder: (context, snapshot) {
          // 1. 데이터 로딩 중 처리
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          // 2. 에러 예외 처리
          if (snapshot.hasError) {
            return Center(
              child: Text(
                '주제를 불러오는 중 오류가 발생했습니다.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          
          // 3. 빈 데이터 검증
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('사용 가능한 대화 주제가 없습니다.'));
          }

          final categories = snapshot.data!;

          // [기존 UI 스타일 복원] Grid 대신 사용자 정의 List 구조로 배치
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              
              // 각 아이템을 커스텀 리스트 카드로 빌드
              return _ListCard(
                category: category,
                onTap: () {
                  // [팀원 라우팅 아키텍처 적용] 
                  // 클릭 시 메인 카테고리 ID를 들고 서브 카테고리 전용 화면으로 이동합니다.
                  Navigator.pushNamed(
                    context,
                    AppRoutes.subCategory,
                    arguments: category.mainCatId,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// [사용자 정의 컴포넌트 1: _ListCard]
/// 기존에 작성해 두셨던 세련된 가로형 리스트 카드 레이아웃입니다.
class _ListCard extends StatelessWidget {
  final MainCategory category;
  final VoidCallback onTap;

  const _ListCard({
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  // 카테고리 아이콘 영역 (포인트 컬러 적용)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EEFF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF8877FF),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // [사용자 정의 컴포넌트 2: _SelectableTextLine]
                  // 텍스트 정렬 및 스타일을 처리하는 전용 내부 컴포넌트 사용
                  Expanded(
                    child: _SelectableTextLine(
                      title: category.title,
                      description: '실전 대화 및 패턴 학습', // 필요시 모델 데이터로 대체 가능
                    ),
                  ),
                  
                  // 우측 내비게이션 인디케이터 화살표
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.black26,
                    size: 16,
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

/// [사용자 정의 컴포넌트 2: _SelectableTextLine]
/// 타이틀과 서브타이틀의 가독성을 높이고 정렬을 제어하는 텍스트 라인 위젯입니다.
class _SelectableTextLine extends StatelessWidget {
  final String title;
  final String description;

  const _SelectableTextLine({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.withValues(alpha : 0.9),
          ),
        ),
      ],
    );
  }
}