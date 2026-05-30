import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../api/api_service.dart';
import '../../controllers/auth_controller.dart';
import '../../design/card_design.dart';
import '../../models/payment_models.dart';
import '../../routes/app_routes.dart';
import '../../services/payment_service.dart';
import '../../services/subscription_storage.dart';
import '../mypage/profile_setting_screen.dart';
import '../mypage/subscription_screen.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final GetStorage _storage = GetStorage();
  final DateFormat _dateFormat = DateFormat('yyyy.MM.dd');

  SubscriptionState _subscription = SubscriptionState.free;
  bool _isSocialUser = false;
  bool _isCancelling = false;
  String _nickname = 'VIPA 사용자';
  String _email = 'user@email.com';

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadSubscription();
  }

  Future<void> _loadUserInfo() async {
    var userData = _storage.read('user_data');

    if (userData == null) {
      try {
        userData = await ApiService.getMyProfile();
        await _storage.write('user_data', userData);
      } catch (error) {
        debugPrint('프로필 조회 실패: $error');
      }
    }

    if (!mounted || userData is! Map) return;

    final isSocial = userData['is_social'] ?? 0;
    setState(() {
      _nickname = (userData['nickname'] ?? _nickname).toString();
      _email = (userData['email'] ?? _email).toString();
      _isSocialUser =
          (isSocial is int
              ? isSocial
              : int.tryParse(isSocial.toString()) ?? 0) >
          0;
    });
  }

  void _loadSubscription() {
    setState(() {
      _subscription = SubscriptionStorage.getState();
    });
  }

  Future<void> _navigateToSubscription() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    );

    if (changed == true && mounted) {
      _loadSubscription();
    }
  }

  Future<void> _cancelSubscription() async {
    final state = _subscription;
    setState(() => _isCancelling = true);

    try {
      if (state.sid != null && state.sid!.isNotEmpty) {
        await PaymentService.inactiveKakaoSubscription(sid: state.sid!);
      }

      await SubscriptionStorage.cancelSubscription(state: state);
      if (!mounted) return;
      Navigator.pop(context);
      _loadSubscription();
      _showSnack('구독이 해지되었습니다.');
    } catch (error) {
      if (!mounted) return;
      _showSnack(PaymentService.describeError(error), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.blueAccent,
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원 탈퇴'),
        content: const Text('탈퇴하면 계정과 학습 데이터가 삭제됩니다. 계속할까요?'),
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
                _showSnack('회원 탈퇴에 실패했습니다.', isError: true);
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

    showDialog<void>(
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
                _showSnack('비밀번호가 변경되었습니다.');
              } else {
                _showSnack('비밀번호 변경에 실패했습니다.', isError: true);
              }
            },
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '구독 해지',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '${_subscription.planName} 구독을 해지할까요?\n해지 후 다음 결제는 진행되지 않습니다.',
        ),
        actions: [
          TextButton(
            onPressed: _isCancelling ? null : () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: _isCancelling ? null : _cancelSubscription,
            child: _isCancelling
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('해지하기', style: TextStyle(color: Colors.redAccent)),
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
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            cardContainer(child: _buildProfileContent(context)),
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
                    ).then((_) => _loadSubscription()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('계정 관리'),
            cardContainer(
              child: Column(
                children: [
                  if (!_isSocialUser)
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      title: '비밀번호 변경',
                      onTap: () => _showChangePasswordDialog(context),
                    ),
                  if (_subscription.active) ...[
                    const Divider(height: 1, indent: 20, endIndent: 20),
                    _buildMenuItem(
                      icon: Icons.cancel_outlined,
                      title: '구독 해지',
                      isDanger: true,
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
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final nextBillingDate = _subscription.nextBillingDate == null
        ? null
        : _dateFormat.format(_subscription.nextBillingDate!);
    final planLabel = _subscription.active ? _subscription.planName : 'FREE';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blueAccent,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nickname,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    Text(
                      _email,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileSettingScreen(),
                  ),
                ),
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
                  if (nextBillingDate != null)
                    Text(
                      '다음 결제: $nextBillingDate',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  planLabel,
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
        onPressed: () =>
            Navigator.pushReplacementNamed(context, AppRoutes.login),
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
