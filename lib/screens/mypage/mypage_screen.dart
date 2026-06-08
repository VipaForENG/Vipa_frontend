import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../api/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../design/app_colors.dart';
import '../../design/card_design.dart'; // 공통 카드 디자인 레이아웃 모듈 적용
import '../../routes/app_routes.dart';
import 'profile_setting_screen.dart';
import 'subscription_screen.dart'; // 멤버십 구독 화면 임포트

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // --- 유저 정보 및 상태 관리 변수 ---
  String nickname = '닉네임';
  String email = 'user@email.com';
  String? profileImage;
  String? localProfileImagePath;
  Map<String, dynamic>? userData;
  bool isSocialUser = false; // 소셜 로그인 유저 여부 플래그 (비밀번호 변경 제어용)

  // --- UI 및 멤버십 구독 상태 변수 ---
  String currentPlan = 'PRO'; 
  String nextBillingDate = '2024.06.20';
  final String loginType = 'email';

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // 초기 화면 진입 시 유저 프로필 데이터 로드
  }

  /// [비즈니스 로직] 로컬 캐시 및 API 서버로부터 사용자 정보를 로드하는 함수
  Future<void> _loadUserInfo({bool forceRefresh = false}) async {
    final storage = GetStorage();
    final cachedData = storage.read('user_data');
    final savedLocalImagePath = storage.read('local_profile_image_path')?.toString();
    
    // HEAD 브랜치의 프로필 이미지 경로 정밀 검증 로직 통합
    final cachedLocalImagePath =
        (savedLocalImagePath != null && savedLocalImagePath.isNotEmpty)
            ? savedLocalImagePath
            : (cachedData is Map
                ? cachedData['local_profile_image_path']?.toString()
                : null);

    // 새로고침 요청(forceRefresh)이 온 경우 스토리지 데이터를 무시하고 새로 호출
    dynamic data = forceRefresh ? null : storage.read('user_data');

    if (data == null) {
      try {
        data = await ApiService.getMyProfile();
        if (cachedLocalImagePath != null && cachedLocalImagePath.isNotEmpty) {
          data['local_profile_image_path'] = cachedLocalImagePath;
        }
        await storage.write('user_data', data);
      } catch (e) {
        debugPrint('프로필 조회 실패: $e');
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      userData = Map<String, dynamic>.from(data);
      nickname = userData?['nickname']?.toString() ?? '닉네임';
      email = userData?['email']?.toString() ?? 'user@email.com';
      profileImage = userData?['profile_image']?.toString();
      localProfileImagePath = userData?['local_profile_image_path']?.toString();
      
      // ff064ac9 브랜치의 소셜 유저 검증 로직 반영 (int타입 유연성 처리)
      final isSocial = userData?['is_social'] ?? 0;
      isSocialUser = (isSocial is int ? isSocial : int.tryParse(isSocial.toString()) ?? 0) > 0;
    });
  }

  /// [네비게이션] 프로필 수정 화면으로 이동 및 수정 결과 리턴 처리
  Future<void> _openProfileSetting() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSettingScreen(initialUserData: userData),
      ),
    );

    if (result == null || !mounted) return;

    // 수정 완료 후 변경된 유저 정보 상태 즉시 업데이트
    setState(() {
      userData = result;
      nickname = result['nickname']?.toString() ?? nickname;
      email = result['email']?.toString() ?? email;
      profileImage = result['profile_image']?.toString();
      localProfileImagePath = result['local_profile_image_path']?.toString();
    });
  }

  /// [네비게이션] 멤버십 구독 및 변경 화면 이동 처리
  void _navigateToSubscription() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    );
  }

  /// [비즈니스 로직] 로그아웃 라우팅 처리 (인증 스택 초기화)
  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // 디자인 시스템 일관성 유지
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      // Pull-to-Refresh 당겨서 새로고침 기능 바인딩 (main 브랜치 기능)
      body: RefreshIndicator(
        onRefresh: () => _loadUserInfo(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // 콘텐츠가 적어도 스크롤 가능하도록 보장
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              // [섹션 1] 프로필 및 현재 구독 플랜 상태 표기
              cardContainer(
                child: _buildProfileContent(context, currentPlan, nextBillingDate),
              ),
              const SizedBox(height: 24),

              // [섹션 2] 멤버십 관리 기능 목록
              _buildSectionHeader('멤버십 관리'),
              cardContainer(
                child: Column(
                  children: [
                    _buildMenuItem(
                      icon: Icons.card_membership_outlined,
                      title: '멤버십 구독 및 변경',
                      onTap: _navigateToSubscription,
                    ),
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.receipt_long_outlined,
                      title: '구독 결제 내역',
                      onTap: () => Navigator.pushNamed(context, AppRoutes.subscriptionHistory),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // [섹션 3] 계정 및 내 정보 관리
              _buildSectionHeader('내 정보 관리'),
              cardContainer(
                child: Column(
                  children: [
                    // 소셜 로그인 사용자가 아닐 때만 비밀번호 변경 옵션 제공
                    if (!isSocialUser)
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        title: '비밀번호 변경',
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                    // 무료 플랜 사용자가 아닐 때만 구독 해지 옵션 활성화
                    if (currentPlan != 'FREE') ...[
                      const Divider(height: 1, indent: 20, endIndent: 20),
                      _buildMenuItem(
                        icon: Icons.cancel_outlined,
                        title: '구독 해지',
                        onTap: () => _showCancelSubscriptionDialog(context),
                      ),
                    ],
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.person_remove_outlined,
                      title: '회원 탈퇴',
                      isDanger: true,
                      onTap: () => _showWithdrawalDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 최하단 텍스트 형태의 로그아웃 버튼 배치
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI 조립 및 컴포넌트 렌더링 헬퍼 메서드 ---

  /// 프로필 카드 내부 콘텐츠 레이아웃 빌더
  Widget _buildProfileContent(BuildContext context, String plan, String nextDate) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              // 컴포넌트 내에 직접 데이터 바인딩하여 렌더링 최적화
              _buildProfileAvatar(radius: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
                    ),
                    Text(
                      email,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _openProfileSetting,
                child: const Text('수정', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('나의 멤버십', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3436))),
                  if (plan != 'FREE')
                    Text('다음 결제: $nextDate', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  plan,
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// [HEAD 최적화 로직 적용] 로컬 파일 유무 확인 후 원격 이미지 폴백 순으로 처리하는 원형 아바타 빌더
  Widget _buildProfileAvatar({required double radius}) {
    final hasLocalImage = localProfileImagePath != null && localProfileImagePath!.isNotEmpty;
    final hasRemoteImage = profileImage != null && profileImage!.isNotEmpty;

    // 기본 대체 아이콘 빌딩
    Widget imageFallback = Container(
      color: Colors.blueAccent.withValues(alpha: 0.2),
      child: const Icon(Icons.person, color: Colors.blueAccent, size: 30),
    );

    Widget activeImage = imageFallback;

    // 1순위: 크롭 또는 로컬에서 업로드하여 유효한 동기화 파일이 캐시에 존재하는 경우
    if (hasLocalImage && File(localProfileImagePath!).existsSync()) {
      activeImage = Image.file(File(localProfileImagePath!), fit: BoxFit.cover);
    } 
    // 2순위: 서버 스토리지 주소가 존재하는 경우 네트워크 캐싱 처리
    else if (hasRemoteImage) {
      activeImage = Image.network(
        profileImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => imageFallback, // 로드 오류 시 폴백 대체
      );
    }

    return ClipOval(
      child: SizedBox(width: radius * 2, height: radius * 2, child: activeImage),
    );
  }

  /// 메뉴 그룹용 섹션 상단 타이틀 텍스트 라벨
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      ),
    );
  }

  /// 단일 메뉴 리스트 아이템 빌더 (공통 디자인 가이드 규격 적용)
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: isDanger ? Colors.redAccent : const Color(0xFF2D3436), size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDanger ? Colors.redAccent : const Color(0xFF2D3436),
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFDFE6E9), size: 20),
      onTap: onTap,
    );
  }

  /// 화면 최하단에 배치되는 단순 언더라인 스타일 로그아웃 버튼
  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: _logout,
        child: const Text(
          '로그아웃',
          style: TextStyle(color: Colors.grey, fontSize: 14, decoration: TextDecoration.underline),
        ),
      ),
    );
  }

  // --- 다이얼로그 모달 구현체 (AuthController 인터페이스 통합) ---

  /// 회원 탈퇴 최종 확인 알림창 및 트랜잭션 처리
  void _showWithdrawalDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('회원 탈퇴', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('탈퇴하면 계정과 모든 학습 데이터가 삭제되며 복구할 수 없습니다. 계속할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              final success = await AuthController.withdrawUser();
              if (!context.mounted) return;

              if (success) {
                Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('탈퇴 처리에 실패했습니다. 다시 시도해주세요.')));
              }
            },
            child: const Text('탈퇴', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// 이메일 회원 전용 비밀번호 변경 폼 다이얼로그
  void _showChangePasswordDialog(BuildContext context) {
    final oldPwController = TextEditingController();
    final newPwController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('비밀번호 변경', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: oldPwController, decoration: const InputDecoration(labelText: '현재 비밀번호'), obscureText: true),
            const SizedBox(height: 12),
            TextField(controller: newPwController, decoration: const InputDecoration(labelText: '새 비밀번호'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              if (oldPwController.text.isEmpty || newPwController.text.isEmpty) return;
              
              final success = await AuthController.changePassword(oldPwController.text, newPwController.text);
              if (!context.mounted) return;

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('비밀번호가 성공적으로 변경되었습니다.')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('변경 실패. 현재 비밀번호를 확인해주세요.')));
              }
            },
            child: const Text('변경', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  /// 멤버십 정기 구독 해지 요청 처리 다이얼로그
  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('구독 해지', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('정말 구독을 해지하시겠습니까? 해지 시 다음 결제일부터 일반 플랜으로 전환됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              // TODO: 실 연동 시 AuthController 또는 Billing 관련 API 해지 서비스 연동 필요
              setState(() => currentPlan = 'FREE'); 
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('구독 해지가 예약되었습니다.')));
            },
            child: const Text('해지하기', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}