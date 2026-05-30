import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../api/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../design/card_design.dart';
import '../../routes/app_routes.dart';
import 'profile_setting_screen.dart';
import 'subscription_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  String currentPlan = 'PRO';
  String nextBillingDate = '2024.06.20';
  String nickname = '닉네임';
  String email = 'user@email.com';
  String? profileImage;
  String? localProfileImagePath;
  bool isSocialUser = false;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

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
      final isSocial = userData?['is_social'] ?? 0;
      isSocialUser =
          (isSocial is int ? isSocial : int.tryParse(isSocial.toString()) ?? 0) >
              0;
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

  Future<void> _navigateToSubscription() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    );

    if (result != null && mounted) {
      setState(() => currentPlan = result);
    }
  }

  void _showWithdrawalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('탈퇴 시 모든 데이터가 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final success = await AuthController.withdrawUser();
              if (!context.mounted) return;

              if (success) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('탈퇴 실패')),
                );
              }
            },
            child: const Text('탈퇴', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPwController = TextEditingController();
    final newPwController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('비밀번호 변경'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPwController,
              decoration: const InputDecoration(labelText: '현재 비밀번호'),
              obscureText: true,
            ),
            TextField(
              controller: newPwController,
              decoration: const InputDecoration(labelText: '새 비밀번호'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              final success = await AuthController.changePassword(
                oldPwController.text,
                newPwController.text,
              );

              if (!context.mounted) return;

              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('변경 완료')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('변경 실패')),
                );
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('구독 해지', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('정말 구독을 해지하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() => currentPlan = 'FREE');
              Navigator.pop(context);
            },
            child: const Text('해지하기', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '마이페이지',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadUserInfo(forceRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            children: [
              cardContainer(
                child: _buildProfileContent(context, currentPlan, nextBillingDate),
              ),
              const SizedBox(height: 24),
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
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.subscriptionHistory,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('내 정보 관리'),
              cardContainer(
                child: Column(
                  children: [
                    if (!isSocialUser)
                      _buildMenuItem(
                        icon: Icons.lock_outline,
                        title: '비밀번호 변경',
                        onTap: () => _showChangePasswordDialog(context),
                      ),
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
              _buildLogoutButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, String plan, String nextDate) {
    final hasImage = profileImage != null && profileImage!.isNotEmpty;
    final hasLocalImage =
        localProfileImagePath != null && localProfileImagePath!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              _buildProfileAvatar(
                radius: 30,
                localPath: hasLocalImage ? localProfileImagePath : null,
                imageUrl: hasImage ? profileImage : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nickname,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
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
                child: const Text(
                  '수정',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '나의 멤버십',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  if (plan != 'FREE')
                    Text(
                      '다음 결제: $nextDate',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
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
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar({
    required double radius,
    String? localPath,
    String? imageUrl,
  }) {
    Widget fallback = Container(
      color: Colors.blueAccent,
      child: const Icon(Icons.person, color: Colors.white, size: 30),
    );

    Widget image = fallback;
    if (localPath != null && File(localPath).existsSync()) {
      image = Image.file(File(localPath), fit: BoxFit.cover);
    } else if (imageUrl != null && imageUrl.isNotEmpty) {
      image = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return ClipOval(
      child: SizedBox(width: radius * 2, height: radius * 2, child: image),
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
      leading: Icon(
        icon,
        color: isDanger ? Colors.redAccent : const Color(0xFF2D3436),
        size: 22,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDanger ? Colors.redAccent : const Color(0xFF2D3436),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Color(0xFFDFE6E9),
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
        child: const Text(
          '로그아웃',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
