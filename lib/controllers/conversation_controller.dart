// lib/screens/conversation/conversation_controller.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../api/api_service.dart'; 
import '../models/conversation_category_model.dart';

class ConversationController {
  // ApiService에 뚫어놓은 인증/로그 인터셉터가 적용된 dio 인스턴스 사용
  static Future<List<MainCategory>> fetchMainCategories() async {
    try {
      // baseUrl이 이미 api_service.dart에 설정되어 있으므로 엔드포인트만 작성
      final response = await ApiService.dio.get('/category/main-categories');

      if (response.statusCode == 200) {
        // Dio는 JSON을 자동으로 Map/List로 파싱해줍니다. jsonDecode 불필요.
        List<dynamic> data = response.data;
        return data.map((json) => MainCategory.fromJson(json)).toList();
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } on DioException {
      throw Exception('네트워크 오류가 발생했습니다.');
    }
  }


  static Future<List<SubCategory>> fetchSubCategories(int mainCatId) async {
    try {
      // 엔드포인트에 mainCatId를 동적으로 삽입 (L3: Dynamic Endpoint)
      final response = await ApiService.dio.get('/category/sub-categories/$mainCatId');

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        // JSON 데이터를 SubCategory 모델 객체 리스트로 변환
        return data.map((json) => SubCategory.fromJson(json)).toList();
      } else {
        throw Exception('소분류 로드 실패: ${response.statusCode}');
      }
    } on DioException {
      throw Exception('소분류를 불러오는 중 네트워크 오류가 발생했습니다.');
    }
  }

}