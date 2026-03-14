import 'package:flutter/material.dart';

/// [클래스] SubscriptionHistoryScreen
/// 목적: 사용자의 과거 구독 결제 및 갱신 내역을 보여주는 화면.
class SubscriptionHistoryScreen extends StatelessWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [가정] 서버에서 받아올 실제 결제 데이터 리스트
    final List<Map<String, dynamic>> billingHistory = [
      {"title": "VIPA PRO 정기 결제", "date": "2026.03.10", "price": 9900, "status": "결제완료", "method": "카카오페이"},
      {"title": "VIPA PRO 정기 결제", "date": "2026.02.10", "price": 9900, "status": "결제완료", "method": "카카오페이"},
      {"title": "VIPA PRO 정기 결제", "date": "2026.01.10", "price": 9900, "status": "결제완료", "method": "카카오페이"},
      {"title": "멤버십 첫 결제 할인", "date": "2025.12.10", "price": 100, "status": "결제완료", "method": "신용카드"},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("구독 결제 내역", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 상단 요약 정보 (선택 사항)
          _buildSummaryHeader(),
          
          Expanded(
            child: billingHistory.isEmpty
                ? const Center(child: Text("결제 내역이 없습니다."))
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: billingHistory.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = billingHistory[index];
                      return _buildHistoryItem(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  /// [위젯] 히스토리 아이템 카드
  Widget _buildHistoryItem(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
            child: const Icon(Icons.receipt_long, color: Colors.blueAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text("${item['date']} • ${item['method']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "₩${item['price'].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Text(
                item['status'],
                style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// [위젯] 상단 요약 배너
  Widget _buildSummaryHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      color: Colors.blueAccent.withValues(alpha: 0.05),
      child: const Text(
        "최근 6개월간의 결제 내역입니다.",
        style: TextStyle(fontSize: 13, color: Colors.blueAccent),
      ),
    );
  }
}