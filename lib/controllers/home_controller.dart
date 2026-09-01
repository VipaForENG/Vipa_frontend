import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'; // DioException 처리를 위해 추가
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

      final response = await ApiService.dio.get('/home/summary');

      if (response.data != null) {
        try {
          summary.value = HomeSummary.fromJson(response.data);
        } catch (_) {
        }
      }
    } finally {
      isLoading(false);
    }
  }
}