import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../design/app_colors.dart'; // 디자인 시스템 일관성을 위한 팀 공통 색상 테마 임포트
import '../../models/payment_models.dart'; // 결제 내역 데이터 모델 
import '../../services/subscription_storage.dart'; // 구독 데이터 영속성 관리를 위한 로컬 저장소 서비스

/// 사용자의 과거 구독 결제 및 해지 내역을 리스트 형태로 보여주는 화면
class SubscriptionHistoryScreen extends StatefulWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  State<SubscriptionHistoryScreen> createState() => _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  // --- 상태 관리 및 포맷 변수 정의 ---
  
  /// 로컬 저장소에서 불러온 결제 내역 리스트 목록
  late List<PaymentHistoryItem> _history;
  
  /// 사용자의 현재 멤버십 활성화 상태 정보 모델
  late SubscriptionState _subscription;

  /// 통화 표시 가격 포맷 (예: 10,000) - 인스턴스 재사용으로 가비지 컬렉션 부담 완화
  final NumberFormat _priceFormat = NumberFormat('#,###');
  
  /// 날짜 표시 포맷 (예: 2026.06.08)
  final DateFormat _dateFormat = DateFormat('yyyy.MM.dd');

  @override
  void initState() {
    super.initState();
    _load(); // 초기 화면 진입 시 결제 데이터 로드
  }

  /// [비즈니스 로직] 데이터 저장소(SubscriptionStorage)로부터 최신 결제 상태를 읽어와 화면을 갱신하는 함수
  void _load() {
    setState(() {
      _history = SubscriptionStorage.getHistory();
      _subscription = SubscriptionStorage.getState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // 전체 화면 배경색 통일
      appBar: AppBar(
        title: const Text(
          '구독 결제 내역',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        // HEAD 브랜치의 AppColors.background 설정을 유지하여 마이페이지와의 UI 일체감 확보
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
          // 상단 영역: 현재 구독 상태 요약 칩 배너
          _buildSummaryHeader(),
          
          // 하단 영역: 결제 내역 리스트 뷰 (데이터 유무에 따른 분기 처리)
          Expanded(
            child: _history.isEmpty
                ? _buildEmptyState() // 내역이 없을 때의 폴백 화면
                : RefreshIndicator(
                    onRefresh: () async => _load(), // 아래로 당겨서 실시간 새로고침 트리거 연동
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

  // --- UI 조립 및 서브 위젯 빌더 ---

  /// [UI 위젯] 상단에 고정되는 현재 구독 플랜 상태 요약 배너
  Widget _buildSummaryHeader() {
    // 구독 활성화 여부에 따른 타이틀 빌딩
    final title = _subscription.active
        ? '${_subscription.planName} 이용 중'
        : '현재 활성화된 구독이 없습니다';
        
    // HEAD의 최적화 코드 적용: 내부 매 build마다 DateFormat을 새로 생성하지 않고 미리 정의된 `_dateFormat` 필드를 재사용함
    final subtitle = _subscription.nextBillingDate == null
        ? '결제 내역을 확인할 수 있습니다.'
        : '다음 결제일 ${_dateFormat.format(_subscription.nextBillingDate!)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: Colors.blueAccent.withValues(alpha: 0.06), // 은은한 브랜드 컬러 포인트 부여
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

  /// [UI 위젯] 결제 내역 리스트가 완전히 비어있을 때 표출되는 안내 프레임
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

  /// [UI 위젯] 개별 결제 트랜잭션 항목을 카드 형태로 시각화하는 컴포넌트
  Widget _buildHistoryItem(PaymentHistoryItem item) {
    // 상태값 스트링에 '해지' 또는 '취소'가 포함되어 있는지 여부 검사
    final isCancel = item.status.contains('해지') || item.status.contains('취소');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 1. 상태별 상태 표시 서클 아이콘 (정상결제: 블루, 해지/정지: 레드)
          CircleAvatar(
            backgroundColor: (isCancel ? Colors.redAccent : Colors.blueAccent).withValues(alpha: 0.1),
            child: Icon(
              isCancel ? Icons.cancel_outlined : Icons.receipt_long,
              color: isCancel ? Colors.redAccent : Colors.blueAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          
          // 2. 텍스트 상세 정보 영역 (유연한 확장을 위해 Expanded 처리)
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
                // [ff064ac9 기능 통합] 아임포트/토스 정기결제 고유 식별 키가 존재하는 경우 유연하게 UI 확장 렌더링
                if (item.sid != null && item.sid!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'sid: ${item.sid}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // 3. 우측 금액 및 트랜잭션 최종 상태 텍스트
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