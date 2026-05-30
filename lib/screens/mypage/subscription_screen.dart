import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_config.dart';
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
      description: '기본 학습 기능을 가볍게 이용할 수 있는 플랜',
      features: ['일부 AI 학습 기능', '기본 학습 기록', '광고 포함'],
    ),
    SubscriptionPlan(
      id: 'pro',
      name: 'VIPA PRO',
      price: 9900,
      description: 'AI 학습 기능을 제한 없이 이용하는 월 구독 플랜',
      features: ['AI 대화 및 피드백 무제한', '모든 프리미엄 학습 콘텐츠', '상세 학습 리포트', '광고 제거'],
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
      if (_subscription.active) {
        _selectedPlanId = _subscription.planId;
      }
    });
  }

  String get _partnerUserId {
    final userData = _storage.read('user_data');
    if (userData is Map) {
      return (userData['user_id'] ??
              userData['email'] ??
              userData['nickname'] ??
              'user-1')
          .toString();
    }
    return 'user-1';
  }

  String _createOrderId(String planId) {
    return 'vipa_${planId}_${DateTime.now().millisecondsSinceEpoch}';
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
      final orderId = _createOrderId(plan.id);
      final ready = await PaymentService.readyKakaoSubscription(
        partnerOrderId: orderId,
        partnerUserId: _partnerUserId,
        itemName: plan.name,
        totalAmount: plan.price,
        approvalUrl: '${ApiConfig.baseUrl}/payments/kakao/redirect/success',
        cancelUrl: '${ApiConfig.baseUrl}/payments/kakao/redirect/cancel',
        failUrl: '${ApiConfig.baseUrl}/payments/kakao/redirect/fail',
      );

      final pending = PendingKakaoPayment(
        tid: ready.tid,
        orderId: orderId,
        partnerUserId: _partnerUserId,
        planId: plan.id,
        planName: plan.name,
        amount: plan.price,
        createdAt: DateTime.now(),
        subscription: true,
      );

      await SubscriptionStorage.savePendingPayment(pending);
      setState(() => _pendingPayment = pending);

      final redirectUrl = ready.browserRedirectUrl;
      if (redirectUrl == null || redirectUrl.isEmpty) {
        throw Exception('카카오페이 결제 URL이 응답에 없습니다.');
      }

      final launched = await launchUrl(
        Uri.parse(redirectUrl),
        mode: kIsWeb
            ? LaunchMode.platformDefault
            : LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('카카오페이 결제창을 열 수 없습니다.');
      }

      if (!mounted) return;
      _showPgTokenDialog(pending);
    } catch (error) {
      if (!mounted) return;
      _showSnack(PaymentService.describeError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
      
      // 1. 먼저 다이얼로그를 닫습니다.
      Navigator.pop(context);

      // 💡 2. 다이얼로그가 닫히는 애니메이션 프레임이 끝난 후 안전하게 스낵바와 이전 화면 복귀를 실행합니다.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showSnack('카카오페이 구독 결제가 완료되었습니다.');
        Navigator.pop(context, true);
      });

    } catch (error) {
      if (!mounted) return;
      _showSnack(PaymentService.describeError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('카카오페이 결제 완료 후 이동한 URL에서 pg_token 값을 복사해 입력하세요.'),
            const SizedBox(height: 12),
            SelectableText(
              'tid: ${pending.tid}\norderId: ${pending.orderId}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pgTokenController,
              decoration: const InputDecoration(
                labelText: 'pg_token',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('나중에 승인'),
          ),
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () => _approvePendingPayment(pending),
            child: const Text('승인 요청'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.blueAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlan = _plans.firstWhere(
      (plan) => plan.id == _selectedPlanId,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '멤버십 구독',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                '나에게 맞는\n학습 플랜을 선택하세요',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                  color: Color(0xFF2D3436),
                ),
              ),
            ),
            if (_subscription.active) _buildCurrentSubscription(),
            if (_pendingPayment != null) _buildPendingPayment(),
            ..._plans.map(_buildPlanCard),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Text(
                '구독은 매월 자동 결제됩니다. 해지는 마이페이지에서 처리할 수 있습니다.',
                style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.6),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildSubscribeButton(selectedPlan),
    );
  }

  Widget _buildCurrentSubscription() {
    return cardContainer(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.verified, color: Colors.blueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${_subscription.planName} 구독 이용 중',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingPayment() {
    final pending = _pendingPayment!;
    return cardContainer(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '승인 대기 중인 결제',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              '${pending.planName} 결제의 pg_token을 받았다면 승인을 완료하세요.',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _showPgTokenDialog(pending),
              child: const Text('pg_token 입력'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    final isSelected = _selectedPlanId == plan.id;
    final isActivePlan =
        _subscription.active && _subscription.planId == plan.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: cardContainer(
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
                children: [
                  Expanded(
                    child: Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.blueAccent
                            : const Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  if (isActivePlan)
                    const Text(
                      '이용 중',
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.blueAccent),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    plan.price == 0 ? '무료' : '₩${plan.formattedPrice}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (plan.price > 0)
                    const Text(
                      ' / 월',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plan.description,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Divider(height: 28),
              ...plan.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(SubscriptionPlan selectedPlan) {
    final isActivePlan =
        _subscription.active && _subscription.planId == selectedPlan.id;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(color: Colors.white),
      child: ElevatedButton(
        onPressed: _isLoading || isActivePlan
            ? null
            : () => _startKakaoPay(selectedPlan),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          disabledBackgroundColor: Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                isActivePlan
                    ? '현재 이용 중인 플랜'
                    : selectedPlan.price == 0
                    ? 'FREE로 변경'
                    : '카카오페이로 시작하기',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
