import 'package:dio/dio.dart';

import '../api/api_service.dart';
import '../models/payment_models.dart';

class PaymentService {
  static Future<KakaoPayReadyResponse> readyKakaoSubscription({
    required String partnerOrderId,
    required String partnerUserId,
    required String itemName,
    required int totalAmount,
    required String approvalUrl,
    required String cancelUrl,
    required String failUrl,
  }) async {
    final response = await ApiService.dio.post(
      '/payments/kakao/subscriptions/ready',
      data: {
        'partner_order_id': partnerOrderId,
        'partner_user_id': partnerUserId,
        'item_name': itemName,
        'quantity': 1,
        'total_amount': totalAmount,
        'tax_free_amount': 0,
        'approval_url': approvalUrl,
        'cancel_url': cancelUrl,
        'fail_url': failUrl,
      },
    );

    return KakaoPayReadyResponse.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  static Future<Map<String, dynamic>> approveKakaoSubscription({
    required String tid,
    required String partnerOrderId,
    required String partnerUserId,
    required String pgToken,
  }) async {
    final response = await ApiService.dio.post(
      '/payments/kakao/subscriptions/approve',
      data: {
        'tid': tid,
        'partner_order_id': partnerOrderId,
        'partner_user_id': partnerUserId,
        'pg_token': pgToken,
      },
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  static Future<Map<String, dynamic>> inactiveKakaoSubscription({
    required String sid,
  }) async {
    final response = await ApiService.dio.post(
      '/payments/kakao/subscriptions/inactive',
      data: {'sid': sid},
    );

    return Map<String, dynamic>.from(response.data as Map);
  }

  static String describeError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      return error.message ?? '결제 요청 중 오류가 발생했습니다.';
    }
    return error.toString();
  }
}
