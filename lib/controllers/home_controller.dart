import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/home_summary_model.dart';
import 'package:vipa/api/api_service.dart';
class HomeController extends GetxController {
  var isLoading = true.obs;
  var summary = Rxn<HomeSummary>();

  @override
  void onInit() {
    super.onInit();
    fetchHomeSummary();
  }

  Future<void> fetchHomeSummary() async {
    try {
      isLoading(true);
      // 이제 인터셉터가 자동으로 토큰을 넣어줍니다.
      final response = await ApiService.dio.get('/home/summary');
      
      if (response.data != null) {
        summary.value = HomeSummary.fromJson(response.data);
      }
    } catch (e) {
      debugPrint("❌ [ERROR] 홈 데이터 로드 실패: $e");
    } finally {
      isLoading(false);
    }
  }
}