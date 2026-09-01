import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import 'api_config.dart';

class ApiService {
  static final String baseUrl = ApiConfig.baseUrl;
  static const _storage = FlutterSecureStorage();

  static final dio_pkg.Dio dio = dio_pkg.Dio(
    dio_pkg.BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout: const Duration(seconds: 45),
      contentType: 'application/json',
    ),
  )..interceptors.addAll([
      dio_pkg.InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (dio_pkg.DioException e, handler) {
          if (e.response?.statusCode == 401) {
            Get.offAllNamed(AppRoutes.login);
          }
          return handler.next(e);
        },
      ),
    ]);

  static Future<Map<String, dynamic>> getMyProfile() async {
    final response = await dio.get('/users/me');
    return Map<String, dynamic>.from(response.data);
  }

  static Future<Map<String, dynamic>> updateMyProfile({
    required String nickname,
    String? imagePath,
  }) async {
    final formData = dio_pkg.FormData.fromMap({
      'nickname': nickname,
      if (imagePath != null)
        'profile_image': await dio_pkg.MultipartFile.fromFile(imagePath),
    });

    final response = await dio.patch(
      '/users/me/profile',
      data: formData,
      options: dio_pkg.Options(contentType: 'multipart/form-data'),
    );
    return Map<String, dynamic>.from(response.data);
  }
}
