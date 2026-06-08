import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_config.dart';
import '../../design/app_colors.dart';
import '../../design/card_design.dart';
import '../../models/payment_models.dart';
import '../../services/payment_service.dart';
import '../../services/subscription_storage.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final TextEditingController _pgTokenController = TextEditingController();
  final GetStorage _storage = GetStorage();

  String _selectedPlanId = 'pro';
  bool _isLoading = false;
  PendingKakaoPayment? _pendingPayment;
  SubscriptionState _subscription = SubscriptionState.free;

  static const List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: 'free',
      name: 'FREE',
      price: 0,
      description: '• 기본 AI 대화 (일 3회)\n• 공용 단어장 열람 가능\n• 광고 포함',
      features: [],
    ),
    SubscriptionPlan(
      id: 'pro',
      name: 'VIPA PRO',
      price: 9900,
      description: '• AI 대화 무제한 이용\n• 모든 프리미엄 단어장 잠금해제\n• 나만의 오답노트 무제한 생성\n• 광고 제거',
      features: [],
      highlight: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  @override
  void dispose() {
    _pgTokenController.dispose();
    super.dispose();
  }

  void _loadState() {
    setState(() {
      _subscription = SubscriptionStorage.getState();
      _pendingPayment = SubscriptionStorage.getPendingPayment();
      if (_subscription.active) _selectedPlanId = _subscription.planId;
    });
  }

  Future<void> _startKakaoPay(SubscriptionPlan plan) async {
    if (plan.price == 0) {
      await SubscriptionStorage.saveState(SubscriptionState.free);
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final orderId = 'vipa_${plan.id}_${DateTime.now().millisecondsSinceEpoch}';
      final ready = await PaymentService.readyKakaoSubscription(
        partnerOrderId: orderId,
        partnerUserId: 'user-1',
        itemName: plan.name,
        totalAmount: plan.price,
        approvalUrl: '${ApiConfig.baseUrl}/payments/kakao/redirect/success',
        cancelUrl: '${ApiConfig.baseUrl}/payments/kakao/redirect/cancel',
        failUrl: '${ApiConfig.baseUrl}/payments/kakao/redirect/fail',
      );

      final pending = PendingKakaoPayment(
        tid: ready.tid,
        orderId: orderId,
        partnerUserId: 'user-1',
        planId: plan.id,
        planName: plan.name,
        amount: plan.price,
        createdAt: DateTime.now(),
        subscription: true,
      );

      await SubscriptionStorage.savePendingPayment(pending);
      setState(() => _pendingPayment = pending);
      await launchUrl(Uri.parse(ready.browserRedirectUrl!), mode: LaunchMode.externalApplication);
      
      if (!mounted) return;
      _showPgTokenDialog(pending);
    } catch (e) {
      _showSnack(PaymentService.describeError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approvePendingPayment(PendingKakaoPayment pending) async {
    final pgToken = _pgTokenController.text.trim();
    if (pgToken.isEmpty) {
      _showSnack('pg_token을 입력해주세요.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await PaymentService.approveKakaoSubscription(
        tid: pending.tid,
        partnerOrderId: pending.orderId,
        partnerUserId: pending.partnerUserId,
        pgToken: pgToken,
      );

      await SubscriptionStorage.activateSubscription(
        pending: pending,
        approveResponse: response,
      );

      _pgTokenController.clear();
      _loadState();

      if (!mounted) return;
      Navigator.pop(context); // 다이얼로그 닫기
      _showSnack('카카오페이 구독 결제가 완료되었습니다.');
    } catch (error) {
      _showSnack(PaymentService.describeError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPgTokenDialog(PendingKakaoPayment pending) {
    _pgTokenController.clear();
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('결제 승인'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('카카오페이 결제 완료 후 이동한 URL에서 pg_token 값을 입력하세요.'),
            const SizedBox(height: 12),
            TextField(
              controller: _pgTokenController,
              decoration: const InputDecoration(labelText: 'pg_token', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(onPressed: () => _approvePendingPayment(pending), child: const Text('승인 요청')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlan = _plans.firstWhere((p) => p.id == _selectedPlanId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("멤버십 구독", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("나에게 꼭 맞는\n학습 플랜을 선택하세요", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4, color: Color(0xFF2D3436))),
            const SizedBox(height: 24),
            if (_pendingPayment != null) _buildPendingCard(),
            ..._plans.map(_buildPlanCard),
            _buildInfoText(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(selectedPlan),
    );
  }

  Widget _buildPendingCard() {
    final pending = _pendingPayment!;
    return cardContainer(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('승인 대기 중인 결제', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _showPgTokenDialog(pending),
              child: const Text('pg_token 입력하여 완료하기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = _selectedPlanId == plan.id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: cardContainer(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? Colors.blueAccent : Colors.transparent, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(plan.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.blueAccent : const Color(0xFF2D3436))),
                  if (isSelected) const Icon(Icons.check_circle, color: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 12),
              Text("₩${plan.price == 0 ? '0' : '9,900'} / 월", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(plan.description, style: TextStyle(color: Colors.grey[600], height: 1.6, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(SubscriptionPlan plan) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(color: Colors.white),
      child: ElevatedButton(
        onPressed: _isLoading ? null : () => _startKakaoPay(plan),
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent, 
            minimumSize: const Size(double.infinity, 56), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
        ),
        child: _isLoading 
            ? const CircularProgressIndicator(color: Colors.white) 
            : Text("${plan.name} 시작하기", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildInfoText() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Text("• 구독은 매월 자동 결제되며 언제든 해지할 수 있습니다.\n• 결제 관련 문의는 고객센터를 이용해주세요.", style: TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: isError ? Colors.redAccent : Colors.blueAccent));
  }
}