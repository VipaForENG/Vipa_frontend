// lib/models/conversation_category.dart

/// 메인 카테고리 (예: 공항, 은행, 병원)
class MainCategory {
  final int mainCatId;
  final String title;

  MainCategory({
    required this.mainCatId, 
    required this.title
  });

  // 백엔드의 JSON 데이터를 Dart 객체로 변환하는 팩토리 생성자
  factory MainCategory.fromJson(Map<String, dynamic> json) {
    return MainCategory(
      mainCatId: json['main_cat_id'] ?? 0, // null 방지 기본값
      title: json['title'] ?? '알 수 없음',
    );
  }
}

/// 서브 카테고리 (예: 공항 -> 출입국 심사)
class SubCategory {
  final int subCatId;
  final int mainCatId;
  final String subTitle;
  final String aiRole;

  SubCategory({
    required this.subCatId, 
    required this.mainCatId, 
    required this.subTitle, 
    required this.aiRole
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subCatId: json['sub_cat_id'] ?? 0,
      mainCatId: json['main_cat_id'] ?? 0,
      subTitle: json['sub_title'] ?? '',
      aiRole: json['ai_role'] ?? '',
    );
  }
}