import 'package:flutter/material.dart';
import '../../design/card_design.dart';
import '../changepw/change_password_screen.dart';
import '../mypage/profile_setting_screen.dart';
import '../mypage/subscription_screen.dart'; // 구독 화면 임포트
import '../../routes/app_routes.dart';

class MyPageScreen extends StatefulWidget {
  const MyPageScreen({super.key});

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  // 상태로 관리할 변수들
  String currentPlan = 'PRO'; 
  String nextBillingDate = '2024.06.20';
  final String loginType = 'email';

  // [핵심] 구독 화면으로 이동하고 결과를 받아오는 함수
  Future<void> _navigateToSubscription() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    );

    // 구독 화면에서 Navigator.pop(context, '플랜명')으로 넘겨준 값을 처리
    if (result != null && result is String) {
      setState(() {
        currentPlan = result;
        // 실제 서비스라면 여기서 서버 데이터를 다시 불러오는 로직이 들어갑니다.
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('마이페이지', 
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          children: [
            // [섹션 1] 프로필 및 구독 상태
            cardContainer(
              child: _buildProfileContent(context, currentPlan, nextBillingDate),
            ),

            const SizedBox(height: 24),

            // [섹션 2] 멤버십 관리
            _buildSectionHeader('멤버십 관리'),
            cardContainer(
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.card_membership_outlined,
                    title: '멤버십 구독 및 변경',
                    onTap: _navigateToSubscription, // 수정된 함수 연결
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

            // [섹션 3] 내 정보 관리
            _buildSectionHeader('내 정보 관리'),
            cardContainer(
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
                  const Divider(height: 1, indent: 20, endIndent: 20),
                  _buildMenuItem(
                    icon: Icons.email_outlined,
                    title: '이메일 변경',
                    onTap: () => debugPrint("이메일 변경 시도"),
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
    );
  }

  // --- 위젯 빌드 함수들 (이전과 동일하지만 currentPlan 변수를 동적으로 사용) ---

  Widget _buildProfileContent(BuildContext context, String plan, String nextDate) {
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('닉네임', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3436))),
                    Text('user@email.com', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingScreen())),
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
                  const Text("나의 멤버십", style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3436))),
                  if (plan != 'FREE')
                    Text("다음 결제: $nextDate", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(plan, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
              ),
            ],
          )
        ],
      ),
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

  Widget _buildMenuItem({required IconData icon, required String title, required VoidCallback onTap, bool isDanger = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, color: isDanger ? Colors.redAccent : const Color(0xFF2D3436), size: 22),
      title: Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isDanger ? Colors.redAccent : const Color(0xFF2D3436))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xFFDFE6E9), size: 20),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
        child: const Text('로그아웃', style: TextStyle(color: Colors.grey, fontSize: 14, decoration: TextDecoration.underline)),
      ),
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

  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('구독 해지', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('정말 구독을 해지하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(onPressed: () {
            setState(() => currentPlan = 'FREE'); // 테스트용 즉시 해지 반영
            Navigator.pop(context);
          }, child: const Text('해지하기', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}