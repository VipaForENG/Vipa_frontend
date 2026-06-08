import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../design/app_colors.dart';
import '../../models/payment_models.dart';
import '../../services/subscription_storage.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  State<SubscriptionHistoryScreen> createState() => _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  late List<PaymentHistoryItem> _history;
  late SubscriptionState _subscription;

  final NumberFormat _priceFormat = NumberFormat('#,###');
  final DateFormat _dateFormat = DateFormat('yyyy.MM.dd');

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    // 실제 저장소에서 데이터를 로드
    setState(() {
      _history = SubscriptionStorage.getHistory();
      _subscription = SubscriptionStorage.getState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "구독 결제 내역",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(),
          Expanded(
            child: _history.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async => _load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _history.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(_history[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// [위젯] 상단 요약 배너
  Widget _buildSummaryHeader() {
    final title = _subscription.active
        ? '${_subscription.planName} 이용 중'
        : '현재 활성화된 구독이 없습니다';
    final subtitle = _subscription.nextBillingDate == null
        ? '결제 내역을 확인할 수 있습니다.'
        : '다음 결제일 ${_dateFormat.format(_subscription.nextBillingDate!)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: Colors.blueAccent.withValues(alpha: 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  /// [위젯] 데이터가 없을 경우
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            '결제 내역이 없습니다.',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// [위젯] 결제 내역 아이템 카드
  Widget _buildHistoryItem(PaymentHistoryItem item) {
    final isCancel = item.status.contains('해지');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: (isCancel ? Colors.redAccent : Colors.blueAccent)
                .withValues(alpha: 0.1),
            child: Icon(
              isCancel ? Icons.cancel_outlined : Icons.receipt_long,
              color: isCancel ? Colors.redAccent : Colors.blueAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_dateFormat.format(item.createdAt)} · ${item.method}',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount == 0 ? '-' : '₩${_priceFormat.format(item.amount)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.status,
                style: TextStyle(
                  color: isCancel ? Colors.redAccent : Colors.blueAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}