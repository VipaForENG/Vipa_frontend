import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

import '../../api/api_service.dart';
import '../../routes/app_routes.dart';
import 'profile_setting_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  static const _primaryColor = Color(0xFFFF4F39);
  static const _pageBackground = Color(0xFFF2F2F2);

  String nickname = '닉네임';
  String email = 'user@email.com';
  String? profileImage;
  String? localProfileImagePath;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo({bool forceRefresh = false}) async {
    final storage = GetStorage();
    final cachedData = storage.read('user_data');
    final savedLocalImagePath = storage.read(
      'local_profile_image_path',
    )?.toString();
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
    // 프로필 수정 화면에서 돌아온 결과를 받아 마이페이지 정보를 즉시 갱신한다.
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

  void _openPasswordRecovery() {
    // 마이페이지 비밀번호 재설정은 비밀번호 찾기 인증 흐름을 재사용한다.
    // 로그인한 사용자의 이메일과 진입 위치를 넘겨 다음 화면들이 같은 플로우를 이어간다.
    Navigator.pushNamed(
      context,
      AppRoutes.resetPassword,
      arguments: <String, dynamic>{'email': email, 'isFromMyPage': true},
    );
  }

  void _showWithdrawalDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('회원탈퇴 기능은 UI만 먼저 연결했습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인', style: TextStyle(color: _primaryColor)),
          ),
        ],
      ),
    );
  }

  void _logout() {
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: RefreshIndicator(
              color: _primaryColor,
              onRefresh: () => _loadUserInfo(forceRefresh: true),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 28),
                children: [
                  const _PageTitle(title: '마이페이지'),
                  const SizedBox(height: 8),
                  _ProfileCard(
                    nickname: nickname,
                    email: email,
                    avatar: _buildProfileAvatar(radius: 24),
                    onEdit: _openProfileSetting,
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    title: '비밀번호 재설정',
                    onPressed: _openPasswordRecovery,
                  ),
                  const SizedBox(height: 8),
                  _MenuButton(
                    title: '회원탈퇴',
                    textColor: _primaryColor,
                    onPressed: _showWithdrawalDialog,
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: _logout,
                    child: const Text(
                      '로그아웃',
                      style: TextStyle(
                        color: Color(0xFF8E8E8E),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar({required double radius}) {
    final hasLocalImage =
        localProfileImagePath != null && localProfileImagePath!.isNotEmpty;
    final hasRemoteImage = profileImage != null && profileImage!.isNotEmpty;

    Widget image = Container(
      color: const Color(0xFFE8E8E8),
      child: const Icon(Icons.person, color: Colors.white, size: 26),
    );
    final fallback = image;

    if (hasLocalImage && File(localProfileImagePath!).existsSync()) {
      image = Image.file(File(localProfileImagePath!), fit: BoxFit.cover);
    } else if (hasRemoteImage) {
      image = Image.network(
        profileImage!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return ClipOval(
      child: SizedBox(width: radius * 2, height: radius * 2, child: image),
    );
  }
}

class _PageTitle extends StatelessWidget {
  const _PageTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            color: _MyPageScreenState._primaryColor,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
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
    return _ShadowPanel(
      height: 76,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            avatar,
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF262626),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9A9A9A),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 58,
              height: 28,
              child: ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _MyPageScreenState._primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  '수정',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.title,
    required this.onPressed,
    this.textColor = Colors.black,
  });

  final String title;
  final VoidCallback onPressed;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return _ShadowPanel(
      height: 36,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ShadowPanel extends StatelessWidget {
  const _ShadowPanel({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
