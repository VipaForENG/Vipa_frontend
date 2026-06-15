import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../api/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../design/app_colors.dart';
import '../../routes/app_routes.dart';
import 'profile_setting_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // 초기 화면 진입 시 유저 프로필 데이터 로드
  }

  /// [비즈니스 로직] 로컬 캐시 및 API 서버로부터 사용자 정보를 로드하는 함수
  Future<void> _loadUserInfo({bool forceRefresh = false}) async {
    final storage = GetStorage();
    final cachedData = storage.read('user_data');
    final savedLocalImagePath = storage
        .read('local_profile_image_path')
        ?.toString();

    // HEAD 브랜치의 프로필 이미지 경로 정밀 검증 로직 통합
    final cachedLocalImagePath =
        (savedLocalImagePath != null && savedLocalImagePath.isNotEmpty)
        ? savedLocalImagePath
        : (cachedData is Map
              ? cachedData['local_profile_image_path']?.toString()
              : null);

    dynamic data;
    try {
      data = await ApiService.getMyProfile();
      if (cachedLocalImagePath != null && cachedLocalImagePath.isNotEmpty) {
        data['local_profile_image_path'] = cachedLocalImagePath;
      }
      await storage.write('user_data', data);
    } catch (e) {
      debugPrint('프로필 조회 실패: $e');
      if (!forceRefresh && cachedData is Map) {
        data = cachedData;
      } else {
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
      isSocialUser = _isSocialAccount(userData);
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
      isSocialUser = _isSocialAccount(result);
    });
  }

  bool _isSocialAccount(Map<String, dynamic>? data) {
    if (data == null) return false;

    final isSocialValue = data['is_social'];
    if (isSocialValue is bool) return isSocialValue;
    if (isSocialValue is num) return isSocialValue > 0;
    if (isSocialValue is String) {
      final normalized = isSocialValue.trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
      if ((int.tryParse(normalized) ?? 0) > 0) return true;
    }

    final socialRole = data['social_role'] ?? data['socialRole'];
    if (socialRole is num && socialRole > 0) return true;
    if (socialRole is String && (int.tryParse(socialRole) ?? 0) > 0) {
      return true;
    }

    final provider =
        (data['provider'] ??
                data['login_provider'] ??
                data['loginProvider'] ??
                data['auth_provider'] ??
                data['authProvider'])
            ?.toString()
            .trim()
            .toLowerCase();
    return provider == 'google' || provider == 'kakao';
  }

  /// [비즈니스 로직] 로그아웃 라우팅 처리 (인증 스택 초기화)
  void _logout() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black, fontSize: 18)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          children: [
            // 1. 프로필 카드
            _ProfileCard(nickname: nickname, email: email, avatar: _buildProfileAvatar(radius: 28), onEdit: _openProfileSetting),
            const SizedBox(height: 32),

            // 2. 계정 관리 카드 (메뉴 그룹화)
            _MenuSectionTitle(title: '계정 설정'),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                children: [
                  if (!isSocialUser) _FlatMenuButton(title: '비밀번호 변경', onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword, arguments: {'isFromMyPage': true})),
                  _FlatMenuButton(title: '회원 탈퇴', textColor: AppColors.primary, onTap: () => _showWithdrawalDialog(context)),
                  _FlatMenuButton(title: '로그아웃', textColor: Colors.grey, onTap: _logout),
                ],
              ),
            ),
            
            // 3. 하단 여백 및 앱 정보
            const SizedBox(height: 40),
            const Center(child: Text('v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12))),
          ],
        ),
      ),
    );
  }

  // --- UI 조립 및 컴포넌트 렌더링 헬퍼 메서드 ---

  /// [HEAD 최적화 로직 적용] 로컬 파일 유무 확인 후 원격 이미지 폴백 순으로 처리하는 원형 아바타 빌더
  Widget _buildProfileAvatar({required double radius}) {
    final hasLocalImage =
        localProfileImagePath != null && localProfileImagePath!.isNotEmpty;
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
        errorBuilder: (_, _, _) => imageFallback, // 로드 오류 시 폴백 대체
      );
    }

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: activeImage,
      ),
    );
  }


  // --- 다이얼로그 모달 구현체 (AuthController 인터페이스 통합) ---

  /// 회원 탈퇴 최종 확인 알림창 및 트랜잭션 처리
  void _showWithdrawalDialog(BuildContext context) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierLabel: '회원 탈퇴 확인',
      barrierColor: Colors.black.withValues(alpha: .55),
      transitionDuration: const Duration(milliseconds: 180),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: .96, end: 1).animate(animation),
          child: child,
        ),
      ),
      pageBuilder: (dialogContext, _, _) {
        bool isWithdrawing = false;
        String? errorMessage;

        return StatefulBuilder(
          builder: (context, setDialogState) => Material(
            color: Colors.transparent,
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 370),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.fromLTRB(26, 30, 26, 22),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0ED),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '회원 탈퇴',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          '탈퇴하면 계정과 모든 학습 데이터가 삭제되며 복구할 수 없습니다. 계속할까요?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            height: 1.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            errorMessage!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: isWithdrawing
                                  ? null
                                  : () => Navigator.pop(dialogContext),
                              child: const Text(
                                '취소',
                                style: TextStyle(
                                  color: Color(0xFFAAAAAA),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 18),
                            TextButton(
                              onPressed: isWithdrawing
                                  ? null
                                  : () async {
                                      setDialogState(() {
                                        isWithdrawing = true;
                                        errorMessage = null;
                                      });
                                      final success =
                                          await AuthController.withdrawUser();
                                      if (!context.mounted) return;

                                      if (success) {
                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          AppRoutes.login,
                                          (route) => false,
                                        );
                                      } else {
                                        setDialogState(() {
                                          isWithdrawing = false;
                                          errorMessage =
                                              '탈퇴 처리에 실패했습니다. 다시 시도해주세요.';
                                        });
                                      }
                                    },
                              child: isWithdrawing
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : const Text(
                                      '탈퇴',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.nickname,
    required this.email,
    required this.avatar,
    required this.onEdit,
  });

  final String nickname;
  final String email;
  final Widget avatar;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(20, 18, 22, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nickname,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 56,
            height: 32,
            child: ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              child: const Text(
                '수정',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlatMenuButton extends StatelessWidget {
  const _FlatMenuButton({required this.title, required this.onTap, this.textColor = Colors.black});
  final String title;
  final VoidCallback onTap;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF5F5F5)))),
        child: Text(title, style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _MenuSectionTitle extends StatelessWidget {
  final String title;
  const _MenuSectionTitle({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 8, bottom: 8),
    child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w800))),
  );
}