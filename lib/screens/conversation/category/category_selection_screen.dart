// lib/screens/conversation/category/category_selection_screen.dart

import 'package:flutter/material.dart';
import '../../../models/conversation_category_model.dart';
import '../../../controllers/conversation_controller.dart'; // API 호출을 위한 컨트롤러
import '../../../routes/app_routes.dart';
import '../../../design/app_colors.dart';

/// [CategorySelectionScreen]
/// 사용자가 실전 회화 학습을 진행할 메인 카테고리(상황)를 선택하는 화면입니다.
/// L3 흐름: initState/build -> ApiService.fetchMainCategories() 호출 -> GridView 렌더링
class CategorySelectionScreen extends StatelessWidget {
  const CategorySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('학습 주제 선택'),
        centerTitle: true,
        elevation: 0,
      ),
      // FutureBuilder: 서버로부터 데이터를 비동기로 받아와 상태에 따라 화면을 분기 처리
      body: FutureBuilder<List<MainCategory>>(
        future:
            ConversationController.fetchMainCategories(), // API 호출 (백엔드와 통신)
        builder: (context, snapshot) {
          // 상태 1: 데이터 로딩 중 (Client -> API 요청 직후)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // 상태 2: 에러 발생 (네트워크 에러, 500 에러 등)
          else if (snapshot.hasError) {
            return Center(
              child: Text(
                '데이터를 불러오지 못했습니다.\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          // 상태 3: 데이터가 비어있을 경우
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('등록된 카테고리가 없습니다.'));
          }

          // 상태 4: 정상적으로 데이터를 받아온 경우 (Response 수신 성공)
          final categories = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2열 격자 구조
              mainAxisSpacing: 16, // 위아래 간격
              crossAxisSpacing: 16, // 좌우 간격
              childAspectRatio: 0.8, // 카드 비율
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(context, categories[index]);
            },
          );
        },
      ),
    );
  }

  /// 개별 카테고리 카드를 생성하는 위젯 함수
  /// [category]: 서버에서 받아온 개별 메인 카테고리 데이터
  Widget _buildCategoryCard(BuildContext context, MainCategory category) {
    return InkWell(
      onTap: () {
        debugPrint(
          '[UI Event] Category Selected: ${category.title} (ID: ${category.mainCatId})',
        );

        // [L3 흐름 수정] Named Route를 호출하며 arguments에 ID를 실어 보냅니다.
        Navigator.pushNamed(
          context,
          AppRoutes.subCategory,
          arguments: category.mainCatId,
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.flight_takeoff,
              size: 50,
              color: Color(0xFF8877FF),
            ),
            const SizedBox(height: 10),
            Text(
              category.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
