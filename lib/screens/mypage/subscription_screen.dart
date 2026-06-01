import 'package:flutter/material.dart';
import '../../design/app_colors.dart';
import '../../design/card_design.dart'; // 디자인 시스템 임포트

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _selectedPlanId = 'pro';

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
      "description":
          "• AI 대화 무제한 이용\n• 모든 프리미엄 단어장 잠금해제\n• 나만의 오답노트 무제한 생성\n• 광고 제거",
      "isHighlight": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // 로그인 화면 톤으로 통일
      appBar: AppBar(
        title: const Text(
          "멤버십 구독",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "나에게 꼭 맞는\n학습 플랜을 선택하세요",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),

            // 디자인 시스템 Card_Container를 활용한 플랜 선택
            ..._plans.map((plan) => _buildPlanCard(plan)),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildInfoText(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubscribeButton(),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final bool isSelected = _selectedPlanId == plan['id'];

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan['id']),
      child: cardContainer(
        // 선택되었을 때 테두리 강조를 위해 cardContainer 내부에 로직 추가 가능
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.blueAccent : Colors.transparent,
              width: 2,
            ),
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.blueAccent
                          : const Color(0xFF2D3436),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    "₩ ${plan['price']}",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    " / 월",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              const Divider(height: 30),
              Text(
                plan['description'],
                style: TextStyle(
                  color: Colors.grey[600],
                  height: 1.6,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoText() {
    return Text(
      "• 구독은 매월 자동으로 갱신됩니다.\n• 다음 결제일 24시간 전까지 언제든 해지 가능합니다.",
      style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.6),
    );
  }

  Widget _buildSubscribeButton() {
    final selectedPlan = _plans.firstWhere((p) => p['id'] == _selectedPlanId);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(color: Colors.white),
      child: ElevatedButton(
        onPressed: () => _showPaymentMethodSheet(selectedPlan),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Text(
          "${selectedPlan['name']} 시작하기",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _showPaymentMethodSheet(Map<String, dynamic> plan) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "결제 수단 선택",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.payment, color: Colors.orange),
              title: const Text("카카오페이"),
              onTap: () => _processPayment(plan),
            ),
            ListTile(
              leading: const Icon(Icons.credit_card, color: Colors.blue),
              title: const Text("신용카드"),
              onTap: () => _processPayment(plan),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(Map<String, dynamic> plan) {
    Navigator.pop(context); // 시트 닫기
    // 여기서 Navigator.pop을 할 때 선택한 플랜 정보를 전달합니다.
    Navigator.pop(context, plan['name']);
  }
}
