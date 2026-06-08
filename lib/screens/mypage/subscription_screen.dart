// [UI] 디자인 시스템 및 플러터 프레임워크 임포트
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // kIsWeb 사용을 위해 추가
import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design/app_colors.dart';
import '../../design/card_design.dart';

// [로직] API, 모델, 결제 및 스토리지 서비스 임포트
import '../../api/api_config.dart';
import '../../models/payment_models.dart';
import '../../services/payment_service.dart';
import '../../services/subscription_storage.dart';

/// 멤버십 구독 화면을 구성하는 StatefulWidget입니다.
/// 사용자가 요금제를 선택하고 카카오페이 결제를 진행할 수 있도록 전체 UI와 결제 흐름을 제어합니다.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  /// 카카오페이 결제 승인을 위해 사용자로부터 pg_token을 직접 입력받는 컨트롤러
  final TextEditingController _pgTokenController = TextEditingController();
  
  /// 로컬 디바이스에 저장된 사용자 데이터를 읽기 위한 GetStorage 인스턴스
  final GetStorage _storage = GetStorage();

  /// 사용자가 화면에서 현재 선택한 요금제 플랜 ID (기본값: pro)
  String _selectedPlanId = 'pro';
  
  /// API 통신 및 화면 전환 중 로딩 스피너를 표시하기 위한 상태 변수
  bool _isLoading = false;
  
  /// 결제 준비 단계는 완료되었으나 승인이 대기 중인 결제 정보 (앱 복귀 시 확인용)
  PendingKakaoPayment? _pendingPayment;
  
  /// 현재 기기 사용자의 구독 상태 정보 (무료/유료 여부 등)
  SubscriptionState _subscription = SubscriptionState.free;

  /// 화면에 표시할 구독 플랜 리스트 (상태 변화가 없는 정적 상수 데이터로 메모리 최적화)
  static const List<SubscriptionPlan> _plans = [
    SubscriptionPlan(
      id: 'free',
      name: 'FREE',
      price: 0,
      description: '• 기본 AI 대화 (일 3회)\n• 공용 단어장 열람 가능\n• 광고 포함',
      features: ['기본 AI 대화 (일 3회)', '공용 단어장 열람', '광고 포함'],
    ),
    SubscriptionPlan(
      id: 'pro',
      name: 'VIPA PRO',
      price: 9900,
      description: '• AI 대화 무제한 이용\n• 모든 프리미엄 단어장 잠금해제\n• 나만의 오답노트 무제한 생성\n• 광고 제거',
      features: ['AI 대화 무제한', '프리미엄 단어장 잠금해제', '오답노트 무제한 생성', '광고 제거'],
      highlight: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    // 화면 최초 진입 시 스토리지에 저장된 구독 정보와 결제 대기 건을 로드
    _loadState();
  }

  @override
  void dispose() {
    // 메모리 누수(Memory Leak)를 방지하기 위해 텍스트 컨트롤러 반드시 해제
    _pgTokenController.dispose();
    super.dispose();
  }

  /// 기기 로컬 스토리지에서 현재 구독 상태와 대기 중인 결제 내역을 불러와 State에 반영합니다.
  void _loadState() {
    setState(() {
      _subscription = SubscriptionStorage.getState();
      _pendingPayment = SubscriptionStorage.getPendingPayment();
      
      // 이미 활성화된 구독 플랜이 존재한다면, 해당 플랜을 기본 선택 상태로 맞춤
      if (_subscription.active) {
        _selectedPlanId = _subscription.planId;
      }
    });
  }

  /// GetStorage에 저장된 사용자 데이터를 바탕으로 결제에 사용할 파트너(유저) ID를 동적으로 생성합니다.
  String get _partnerUserId {
    final userData = _storage.read('user_data');
    if (userData is Map) {
      // user_id, email, nickname 순으로 탐색하여 식별자 반환
      return (userData['user_id'] ?? userData['email'] ?? userData['nickname'] ?? 'user-1').toString();
    }
    return 'user-1'; // 데이터가 없을 경우 기본값 폴백
  }

  /// 결제 고유 주문번호(Order ID)를 생성합니다. (현재 시간 타임스탬프를 조합하여 중복 방지)
  String _createOrderId(String planId) {
    return 'vipa_${planId}_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// 사용자가 선택한 플랜으로 카카오페이 결제 준비(Ready) API를 호출하고 외부 브라우저를 엽니다.
  Future<void> _startKakaoPay(SubscriptionPlan plan) async {
    // 0원(무료) 플랜 선택 시 결제 API 호출 없이 바로 로컬 구독 상태를 무료로 변경하고 화면 종료
    if (plan.price == 0) {
      await SubscriptionStorage.saveState(SubscriptionState.free);
      if (!mounted) return;
      Navigator.pop(context, true);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final orderId = _createOrderId(plan.id);
      final partnerUserId = _partnerUserId; // 동적으로 파트너 유저 ID 획득

      // 1. 카카오페이 결제 Ready 요청 (백엔드 서버 경유)
      final ready = await PaymentService.readyKakaoSubscription(
        partnerOrderId: orderId,
        partnerUserId: partnerUserId,
        itemName: plan.name,
        totalAmount: plan.price,
        approvalUrl: '${ApiConfig.baseUrl}/payments/kakao/redirect/success',
        cancelUrl: '${ApiConfig.baseUrl}/payments/kakao/redirect/cancel',
        failUrl: '${ApiConfig.baseUrl}/payments/kakao/redirect/fail',
      );

      // 2. 결제 승인에 사용할 대기 상태(Pending) 객체 생성
      final pending = PendingKakaoPayment(
        tid: ready.tid,
        orderId: orderId,
        partnerUserId: partnerUserId,
        planId: plan.id,
        planName: plan.name,
        amount: plan.price,
        createdAt: DateTime.now(),
        subscription: true,
      );

      // 3. 앱 종료나 백그라운드 전환에 대비해 로컬 스토리지에 대기 건 임시 저장
      await SubscriptionStorage.savePendingPayment(pending);
      setState(() => _pendingPayment = pending);

      // 4. 응답받은 결제 리다이렉트 URL 파싱 및 유효성 검증
      final redirectUrl = ready.browserRedirectUrl;
      if (redirectUrl == null || redirectUrl.isEmpty) {
        throw Exception('카카오페이 결제 URL이 응답에 없습니다.');
      }

      // 5. URL 런처를 통해 브라우저 열기 (웹/앱 환경에 따라 모드 분기)
      final launched = await launchUrl(
        Uri.parse(redirectUrl),
        mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      );

      if (!launched) {
        throw Exception('카카오페이 결제창을 열 수 없습니다.');
      }

      // 브라우저 전환 후, 앱 내에서는 pg_token을 입력할 수 있는 다이얼로그 띄우기
      if (!mounted) return;
      _showPgTokenDialog(pending);
    } catch (e) {
      _showSnack(PaymentService.describeError(e), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 브라우저에서 결제 완료 후 획득한 pg_token을 통해 최종 결제 승인(Approve)을 백엔드에 요청합니다.
  Future<void> _approvePendingPayment(PendingKakaoPayment pending) async {
    final pgToken = _pgTokenController.text.trim();
    if (pgToken.isEmpty) {
      _showSnack('pg_token을 입력해주세요.', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 1. 카카오페이 결제 승인 요청
      final response = await PaymentService.approveKakaoSubscription(
        tid: pending.tid,
        partnerOrderId: pending.orderId,
        partnerUserId: pending.partnerUserId,
        pgToken: pgToken,
      );

      // 2. 승인 성공 시 로컬 상태를 '구독 중(Active)'으로 갱신
      await SubscriptionStorage.activateSubscription(
        pending: pending,
        approveResponse: response,
      );

      _pgTokenController.clear();
      _loadState(); // UI 상태 업데이트를 위해 최신 구독 정보 다시 로드

      if (!mounted) return;
      Navigator.pop(context); // pg_token 입력 다이얼로그 닫기

      // 팝업이 닫힌 이후 안전한 라우팅 및 스낵바 표시를 위해 콜백 사용 (프레임 크래시 방지)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _showSnack('카카오페이 구독 결제가 완료되었습니다.');
        Navigator.pop(context, true); // 성공 처리 후 구독 화면 최종 이탈
      });
    } catch (error) {
      _showSnack(PaymentService.describeError(error), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// 딥링크 미설정 환경을 대비하여 수동으로 pg_token을 입력받는 모달 창을 띄웁니다.
  void _showPgTokenDialog(PendingKakaoPayment pending) {
    _pgTokenController.clear();
    showDialog<void>(
      context: context,
      barrierDismissible: false, // 결제 도중 배경 탭으로 인한 창 닫힘 방지
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('나중에 승인'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () => _approvePendingPayment(pending),
            child: const Text('승인 요청'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 사용자가 현재 클릭해둔 플랜 데이터 추출
    final selectedPlan = _plans.firstWhere((plan) => plan.id == _selectedPlanId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "멤버십 구독",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
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
            // 이미 구독을 보유한 사용자라면 안내 배너 렌더링
            if (_subscription.active) _buildCurrentSubscription(),
            // 결제 브라우저 전환 후 돌아왔을 때 대기 중인 결제 카드 렌더링
            if (_pendingPayment != null) _buildPendingPayment(),
            
            // 등록된 전체 플랜 정보를 카드로 변환하여 렌더링 (map 확산 연산자)
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
      // 화면 최하단 고정 결제 진행 버튼
      bottomNavigationBar: _buildSubscribeButton(selectedPlan),
    );
  }

  /// 현재 이용 중인 멤버십 요금제 배너 UI 위젯
  Widget _buildCurrentSubscription() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '현재 ${_subscription.planId.toUpperCase()} 플랜을 이용 중입니다.',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  /// 미승인(대기) 결제 건에 대한 재개(Resume) UI 위젯
  Widget _buildPendingPayment() {
    final pending = _pendingPayment!;
    return cardContainer( // 공통 카드 디자인 적용
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('승인 대기 중인 결제', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              '${pending.planName} 결제의 pg_token을 받았다면 승인을 완료하세요.',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
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

  /// 개별 구독 요금제(Plan) 정보를 표시하는 카드 UI 위젯
  Widget _buildPlanCard(SubscriptionPlan plan) {
    // 탭 된 플랜인지 확인
    final isSelected = _selectedPlanId == plan.id;
    // 현재 기기 사용자가 보유한 플랜인지 확인
    final isActivePlan = _subscription.active && _subscription.planId == plan.id;

    // 가격 표시용 텍스트 포매팅 (세 자리 콤마)
    final priceStr = plan.price == 0 
        ? '무료' 
        : '₩${plan.price.toString().replaceAll(RegExp(r'\B(?=(\d{3})+(?!\d))'), ',')}';

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: cardContainer(
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
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
                  Expanded(
                    child: Text(
                      plan.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.blueAccent : const Color(0xFF2D3436),
                      ),
                    ),
                  ),
                  if (isActivePlan)
                    const Text('이용 중', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
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
                    priceStr,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  if (plan.price > 0)
                    const Text(' / 월', style: TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 8),
              Text(plan.description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const Divider(height: 28),
              // features 목록을 순회하며 체크 아이콘과 함께 출력
              ...plan.features.map(
                (feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 18, color: Colors.blueAccent),
                      const SizedBox(width: 8),
                      Expanded(child: Text(feature, style: const TextStyle(fontSize: 13, height: 1.4))),
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

  /// 하단 고정 영역 - 선택한 요금제 결제를 시작하는 버튼 UI 위젯
  Widget _buildSubscribeButton(SubscriptionPlan selectedPlan) {
    final isActivePlan = _subscription.active && _subscription.planId == selectedPlan.id;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: const BoxDecoration(color: Colors.white),
      child: ElevatedButton(
        // 통신 중이거나 이미 사용 중인 플랜인 경우 버튼 비활성화 (null 반환)
        onPressed: _isLoading || isActivePlan ? null : () => _startKakaoPay(selectedPlan),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          disabledBackgroundColor: Colors.grey.shade300,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(
                isActivePlan
                    ? '현재 이용 중인 플랜'
                    : selectedPlan.price == 0
                        ? 'FREE로 변경'
                        : '카카오페이로 시작하기',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }

  /// 화면 하단에 알림 메시지를 표시하는 공통 스낵바 위젯
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.blueAccent,
      ),
    );
  }
}