class KakaoPayReadyResponse {
  const KakaoPayReadyResponse({
    required this.tid,
    required this.createdAt,
    this.nextRedirectPcUrl,
    this.nextRedirectMobileUrl,
    this.nextRedirectAppUrl,
    this.androidAppScheme,
    this.iosAppScheme,
  });

  final String tid;
  final DateTime? createdAt;
  final String? nextRedirectPcUrl;
  final String? nextRedirectMobileUrl;
  final String? nextRedirectAppUrl;
  final String? androidAppScheme;
  final String? iosAppScheme;

  factory KakaoPayReadyResponse.fromJson(Map<String, dynamic> json) {
    return KakaoPayReadyResponse(
      tid: json['tid']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      nextRedirectPcUrl: json['next_redirect_pc_url']?.toString(),
      nextRedirectMobileUrl: json['next_redirect_mobile_url']?.toString(),
      nextRedirectAppUrl: json['next_redirect_app_url']?.toString(),
      androidAppScheme: json['android_app_scheme']?.toString(),
      iosAppScheme: json['ios_app_scheme']?.toString(),
    );
  }

  String? get browserRedirectUrl =>
      nextRedirectMobileUrl ?? nextRedirectPcUrl ?? nextRedirectAppUrl;
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.features,
    this.highlight = false,
  });

  final String id;
  final String name;
  final int price;
  final String description;
  final List<String> features;
  final bool highlight;

  String get formattedPrice {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }
}

class PendingKakaoPayment {
  const PendingKakaoPayment({
    required this.tid,
    required this.orderId,
    required this.partnerUserId,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.createdAt,
    required this.subscription,
  });

  final String tid;
  final String orderId;
  final String partnerUserId;
  final String planId;
  final String planName;
  final int amount;
  final DateTime createdAt;
  final bool subscription;

  Map<String, dynamic> toJson() {
    return {
      'tid': tid,
      'orderId': orderId,
      'partnerUserId': partnerUserId,
      'planId': planId,
      'planName': planName,
      'amount': amount,
      'createdAt': createdAt.toIso8601String(),
      'subscription': subscription,
    };
  }

  factory PendingKakaoPayment.fromJson(Map<String, dynamic> json) {
    return PendingKakaoPayment(
      tid: json['tid']?.toString() ?? '',
      orderId: json['orderId']?.toString() ?? '',
      partnerUserId: json['partnerUserId']?.toString() ?? '',
      planId: json['planId']?.toString() ?? '',
      planName: json['planName']?.toString() ?? '',
      amount: int.tryParse(json['amount']?.toString() ?? '') ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      subscription: json['subscription'] == true,
    );
  }
}

class SubscriptionState {
  const SubscriptionState({
    required this.planId,
    required this.planName,
    required this.active,
    this.sid,
    this.tid,
    this.approvedAt,
    this.nextBillingDate,
  });

  final String planId;
  final String planName;
  final bool active;
  final String? sid;
  final String? tid;
  final DateTime? approvedAt;
  final DateTime? nextBillingDate;

  static const free = SubscriptionState(
    planId: 'free',
    planName: 'FREE',
    active: false,
  );

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'planName': planName,
      'active': active,
      'sid': sid,
      'tid': tid,
      'approvedAt': approvedAt?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
    };
  }

  factory SubscriptionState.fromJson(Map<String, dynamic> json) {
    return SubscriptionState(
      planId: json['planId']?.toString() ?? 'free',
      planName: json['planName']?.toString() ?? 'FREE',
      active: json['active'] == true,
      sid: json['sid']?.toString(),
      tid: json['tid']?.toString(),
      approvedAt: DateTime.tryParse(json['approvedAt']?.toString() ?? ''),
      nextBillingDate: DateTime.tryParse(
        json['nextBillingDate']?.toString() ?? '',
      ),
    );
  }
}

class PaymentHistoryItem {
  const PaymentHistoryItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.tid,
    this.sid,
  });

  final String id;
  final String title;
  final int amount;
  final String method;
  final String status;
  final DateTime createdAt;
  final String? tid;
  final String? sid;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'method': method,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'tid': tid,
      'sid': sid,
    };
  }

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    return PaymentHistoryItem(
      id:
          json['id']?.toString() ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? '결제',
      amount: int.tryParse(json['amount']?.toString() ?? '') ?? 0,
      method: json['method']?.toString() ?? '카카오페이',
      status: json['status']?.toString() ?? '완료',
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      tid: json['tid']?.toString(),
      sid: json['sid']?.toString(),
    );
  }
}
