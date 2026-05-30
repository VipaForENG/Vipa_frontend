import 'package:get_storage/get_storage.dart';

import '../models/payment_models.dart';

class SubscriptionStorage {
  static final GetStorage _box = GetStorage();

  static const String _stateKey = 'subscription_state';
  static const String _historyKey = 'subscription_payment_history';
  static const String _pendingKey = 'pending_kakao_payment';

  static SubscriptionState getState() {
    final data = _box.read(_stateKey);
    if (data is Map) {
      return SubscriptionState.fromJson(Map<String, dynamic>.from(data));
    }
    return SubscriptionState.free;
  }

  static Future<void> saveState(SubscriptionState state) {
    return _box.write(_stateKey, state.toJson());
  }

  static PendingKakaoPayment? getPendingPayment() {
    final data = _box.read(_pendingKey);
    if (data is Map) {
      return PendingKakaoPayment.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  static Future<void> savePendingPayment(PendingKakaoPayment payment) {
    return _box.write(_pendingKey, payment.toJson());
  }

  static Future<void> clearPendingPayment() {
    return _box.remove(_pendingKey);
  }

  static List<PaymentHistoryItem> getHistory() {
    final rawList = _box.read(_historyKey);
    if (rawList is! List) {
      return [];
    }

    final items =
        rawList
            .whereType<Map>()
            .map(
              (item) =>
                  PaymentHistoryItem.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return items;
  }

  static Future<void> addHistory(PaymentHistoryItem item) async {
    final history = getHistory();
    history.insert(0, item);
    await _box.write(
      _historyKey,
      history.map((historyItem) => historyItem.toJson()).toList(),
    );
  }

  static Future<void> activateSubscription({
    required PendingKakaoPayment pending,
    required Map<String, dynamic> approveResponse,
  }) async {
    final now = DateTime.now();
    final sid = approveResponse['sid']?.toString();

    await saveState(
      SubscriptionState(
        planId: pending.planId,
        planName: pending.planName,
        active: true,
        sid: sid,
        tid: pending.tid,
        approvedAt: now,
        nextBillingDate: DateTime(now.year, now.month + 1, now.day),
      ),
    );

    await addHistory(
      PaymentHistoryItem(
        id: 'pay_${now.microsecondsSinceEpoch}',
        title: '${pending.planName} 정기 결제',
        amount: pending.amount,
        method: '카카오페이',
        status: '결제완료',
        createdAt: now,
        tid: pending.tid,
        sid: sid,
      ),
    );

    await clearPendingPayment();
  }

  static Future<void> cancelSubscription({
    required SubscriptionState state,
  }) async {
    final now = DateTime.now();
    await saveState(SubscriptionState.free);
    await addHistory(
      PaymentHistoryItem(
        id: 'cancel_${now.microsecondsSinceEpoch}',
        title: '${state.planName} 구독 해지',
        amount: 0,
        method: '카카오페이',
        status: '해지완료',
        createdAt: now,
        tid: state.tid,
        sid: state.sid,
      ),
    );
  }
}
