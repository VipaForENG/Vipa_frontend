import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../api/api_service.dart';
import '../../design/app_colors.dart';
import '../../routes/app_routes.dart';
import '../changepw/change_password_screen.dart'; // 이전 화면에서 쓰던 경로에 맞게 임포트
import 'profile_setting_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // --- 상태 데이터 (HEAD 로직 통합) ---
  String nickname = '닉네임';
  String email = 'user@email.com';
  String? profileImage;
  String? localProfileImagePath;
  Map<String, dynamic>? userData;

  // UI 상태 변수
  String currentPlan = 'PRO'; 
  String nextBillingDate = '2024.06.20';
  final String loginType = 'email';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  // --- 비즈니스 로직 (HEAD 통합) ---

  Future<void> _loadUserInfo({bool forceRefresh = false}) async {
    final storage = GetStorage();
    final cachedData = storage.read('user_data');
    final savedLocalImagePath = storage.read('local_profile_image_path')?.toString();
    
    final cachedLocalImagePath =
        (savedLocalImagePath != null && savedLocalImagePath.isNotEmpty)
            ? savedLocalImagePath
            : (cachedData is Map
                ? cachedData['local_profile_image_path']?.toString()
                : null);

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
    });
  }

  Future<void> _openProfileSetting() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileSettingScreen(initialUserData: userData),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      userData = result;
      nickname = result['nickname']?.toString() ?? nickname;
      email = result['email']?.toString() ?? email;
      profileImage = result['profile_image']?.toString();
      localProfileImagePath = result['local_profile_image_path']?.toString();
    });
  }

  void _logout() {
    // 로그아웃 시 스택 초기화
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  // --- UI 구현 (vipa_front-dev 기반) ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // [섹션 1] 프로필
            _cardContainer(
              child: _buildProfileContent(context),
            ),
            const SizedBox(height: 24),

            // [섹션 2] 멤버십 관리
            _buildSectionHeader('멤버십 관리'),
            _cardContainer(
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.receipt_long_outlined,
                    title: '구독 결제 내역',
                    onTap: () => Navigator.pushNamed(context, AppRoutes.subscriptionHistory),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // [섹션 3] 내 정보 관리
            _buildSectionHeader('내 정보 관리'),
            _cardContainer(
              child: Column(
                children: [
                  if (loginType == 'email')
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      title: '비밀번호 변경',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordScreen(isFromMyPage: true)),
                      ),
                    ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    title: '로그아웃',
                    onTap: _logout,
                  ),
                  _buildMenuItem(
                    icon: Icons.delete_forever,
                    title: '회원 탈퇴',
                    isDanger: true,
                    onTap: () => _showWithdrawalDialog(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI Helper Methods ---

  Widget _buildProfileContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _buildProfileAvatar(radius: 30), // 통합된 아바타 로직
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nickname, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                    Text(email, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              TextButton(
                onPressed: _openProfileSetting,
                child: const Text('수정', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // HEAD에서 가져온 강력한 프로필 이미지 처리 로직
  Widget _buildProfileAvatar({required double radius}) {
    final hasLocalImage = localProfileImagePath != null && localProfileImagePath!.isNotEmpty;
    final hasRemoteImage = profileImage != null && profileImage!.isNotEmpty;

    Widget image = Container(
      color: Colors.blueAccent.withValues(alpha: 0.2),
      child: const Icon(Icons.person, color: Colors.blueAccent, size: 30),
    );

    if (hasLocalImage && File(localProfileImagePath!).existsSync()) {
      image = Image.file(File(localProfileImagePath!), fit: BoxFit.cover);
    } else if (hasRemoteImage) {
      image = Image.network(
        profileImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => image,
      );
    }

    return ClipOval(
      child: SizedBox(width: radius * 2, height: radius * 2, child: image),
    );
  }

  Widget _cardContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: isDanger ? Colors.redAccent : const Color(0xFF2D3436), size: 22),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDanger ? Colors.redAccent : const Color(0xFF2D3436))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFDFE6E9), size: 20),
      onTap: onTap,
    );
  }

  void _showWithdrawalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('회원 탈퇴', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('탈퇴 시 모든 학습 데이터가 삭제되며 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('탈퇴', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}