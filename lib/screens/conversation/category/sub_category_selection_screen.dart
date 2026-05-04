// lib/screens/conversation/category/sub_category_selection_screen.dart

import 'package:flutter/material.dart';
import '../../../controllers/conversation_controller.dart'; // API 호출을 위한 컨트롤러
import '../../../models/conversation_category_model.dart';
import '../../../routes/app_routes.dart';

class SubCategorySelectionScreen extends StatelessWidget {
  final int mainCatId; // 대분류에서 넘어온 ID

  const SubCategorySelectionScreen({super.key, required this.mainCatId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('세부 시나리오 선택')),
      body: FutureBuilder<List<SubCategory>>(
        future: ConversationController.fetchSubCategories(mainCatId), // ID를 전달하여 호출
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('에러: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('등록된 시나리오가 없습니다.'));
          }

          final subCategories = snapshot.data!;
          return ListView.builder( // 소분류는 텍스트가 길 수 있으므로 ListView 추천
            padding: const EdgeInsets.all(16),
            itemCount: subCategories.length,
            itemBuilder: (context, index) {
              final sub = subCategories[index];
              return ListTile(
                title: Text(sub.subTitle),
                subtitle: const Text('원어민 AI와 대화하기'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // 최종 채팅 화면으로 이동 (SubCategory 정보를 들고 이동)
                  Navigator.pushNamed(
                    context, 
                    AppRoutes.conversation, 
                    arguments: sub, // 이번엔 ID가 아니라 sub 객체 자체를 넘기는 것을 고려
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