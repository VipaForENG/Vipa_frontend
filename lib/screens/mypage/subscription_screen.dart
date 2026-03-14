import 'package:flutter/material.dart';

/// [클래스] SubscriptionScreen
/// 목적: 사용자가 멤버십 플랜(Free/Pro)을 선택하고 정기 결제를 시작하는 화면.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  // 현재 선택된 플랜 ID (기본값: PRO)
  String _selectedPlanId = 'pro';

  // 플랜 데이터 리스트 (추후 백엔드 API와 연동)
  final List<Map<String, dynamic>> _plans = [
    {
      "id": "free",
      "name": "FREE",
      "price": "0",
      "description": "• 기본 AI 대화 (일 3회)\n• 공용 단어장 열람 가능\n• 광고 포함",
      "isHighlight": false,
    },
    {
      "id": "pro",
      "name": "VIPA PRO",
      "price": "9,900",
      "description": "• AI 대화 무제한 이용\n• 모든 프리미엄 단어장 잠금해제\n• 나만의 오답노트 무제한 생성\n• 광고 제거",
      "isHighlight": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("멤버십 구독", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "나에게 꼭 맞는\n학습 플랜을 선택하세요",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
            ),
            const SizedBox(height: 24),
            
            // 구독 플랜 리스트 빌드
            ..._plans.map((plan) => _buildPlanCard(plan)),
            
            const SizedBox(height: 20),
            _buildInfoText(),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubscribeButton(),
    );
  }

  /// [위젯] 플랜 선택 카드
  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final bool isSelected = _selectedPlanId == plan['id'];
    final bool isHighlight = plan['isHighlight'];

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan['id']),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blueAccent : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  plan['name'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isHighlight ? Colors.blueAccent : Colors.black87,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: Colors.blueAccent),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              textBaseline: TextBaseline.alphabetic,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              children: [
                const Text("₩ ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  plan['price'],
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(" / 월", style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
            const Divider(height: 32),
            Text(
              plan['description'],
              style: TextStyle(color: Colors.grey.shade700, height: 1.8, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  /// [위젯] 하단 유의사항
  Widget _buildInfoText() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "• 구독은 매월 자동으로 갱신됩니다.\n• 다음 결제일 24시간 전까지 언제든 해지 가능합니다.\n• 무료 체험은 최초 1회에 한하여 제공됩니다.",
        style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.6),
      ),
    );
  }

  /// [위젯] 하단 구독하기 버튼
  Widget _buildSubscribeButton() {
    final selectedPlan = _plans.firstWhere((p) => p['id'] == _selectedPlanId);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ElevatedButton(
        onPressed: () => _showPaymentMethodSheet(selectedPlan['name']),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: Text(
          _selectedPlanId == 'free' ? "기본 플랜으로 계속하기" : "${selectedPlan['name']} 시작하기",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  /// [함수] 결제 수단 선택 시트
  void _showPaymentMethodSheet(String planName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("결제 수단 선택", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.yellow),
              title: const Text("카카오페이"),
              onTap: () => _processPayment(planName, "카카오페이"),
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.blue),
              title: const Text("토스"),
              onTap: () => _processPayment(planName, "토스"),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text("신용/체크카드"),
              onTap: () => _processPayment(planName, "카드"),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(String planName, String method) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("결제 완료"),
        content: Text("$planName 구독이 시작되었습니다.\n수단: $method"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("확인")),
        ],
      ),
    );
  }
}