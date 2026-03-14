import 'package:flutter/material.dart';
import '../changepw/change_password_screen.dart';
import '../mypage/profile_setting_screen.dart';
import '../../routes/app_routes.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String loginType = 'email'; 
    const String currentPlan = 'PRO'; // 가상 데이터
    const String nextBillingDate = '2024.06.20'; // 다음 결제 예정일 가상 데이터

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), 
      appBar: AppBar(
        title: const Text('마이페이지', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          children: [
            // [섹션 1] 프로필 및 구독 상태 카드
            _buildProfileCard(context, currentPlan, nextBillingDate),
            const SizedBox(height: 30),

            // [섹션 2] 멤버십 관리
            _buildSectionTitle('멤버십 관리'),
            _buildMenuCard([
              _buildMenuItem(
                icon: Icons.card_membership_outlined, 
                title: '멤버십 구독 및 변경', 
                onTap: () => Navigator.pushNamed(context, AppRoutes.subscription),
              ),
              _buildMenuItem(
                icon: Icons.receipt_long_outlined, 
                title: '구독 결제 내역', 
                onTap: () => Navigator.pushNamed(context, AppRoutes.subscriptionHistory),
              ),
            ]),
            const SizedBox(height: 30),

            // [섹션 3] 내 정보 관리
            _buildSectionTitle('내 정보 관리'),
            _buildMenuCard([
              if (loginType == 'email')
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: '비밀번호 변경',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(isFromMyPage: true),
                      ),
                    );
                  },
                ),
              _buildMenuItem(
                icon: Icons.email_outlined, 
                title: '이메일 변경', 
                onTap: () => debugPrint("이메일 변경 시도"),
              ),
              // [추가] 구독 해지 버튼
              if (currentPlan != 'FREE')
                _buildMenuItem(
                  icon: Icons.cancel_outlined, 
                  title: '구독 해지', 
                  onTap: () => _showCancelSubscriptionDialog(context),
                ),
              _buildMenuItem(
                icon: Icons.person_remove_outlined, 
                title: '회원 탈퇴', 
                onTap: () => _showWithdrawalDialog(context), 
                isDanger: true,
              ),
            ]),

            const SizedBox(height: 30),
            
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  /// [수정] 프로필 카드에 다음 결제일 정보 추가
  Widget _buildProfileCard(BuildContext context, String plan, String nextDate) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 35, 
                backgroundColor: Colors.blueAccent, 
                child: Icon(Icons.person, color: Colors.white, size: 40),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('닉네임', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('user@email.com', style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileSettingScreen()),
                  );
                }, 
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blueAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('프로필 수정'),
              ),
            ],
          ),
          const Divider(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("나의 멤버십 플랜", style: TextStyle(fontWeight: FontWeight.w500)),
                  if (plan != 'FREE')
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text("다음 결제일: $nextDate", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  plan,
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap, 
    bool isDanger = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : Colors.blueAccent),
      title: Text(
        title, 
        style: TextStyle(
          fontWeight: FontWeight.w500, 
          color: isDanger ? Colors.red : Colors.black87,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 5),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
      icon: const Icon(Icons.logout, color: Colors.grey),
      label: const Text('로그아웃', style: TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }

  /// [함수] 구독 해지 확인 다이얼로그
  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('구독 해지', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('정말 구독을 해지하시겠습니까?\n해지 시 이번 결제 주기까지는 혜택이 유지됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              debugPrint("구독 해지 로직 실행");
              Navigator.pop(context);
            }, 
            child: const Text('해지하기', style: TextStyle(color: Colors.red))
          ),
        ],
      ),
    );
  }

  void _showWithdrawalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('회원 탈퇴', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text('정말로 VIPA를 떠나시겠어요?\n탈퇴 시 모든 학습 데이터와 단어장이 삭제되며 복구할 수 없습니다.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소', style: TextStyle(color: Colors.grey))),
            TextButton(
              onPressed: () {
                debugPrint("회원 탈퇴 프로세스 시작");
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: const Text('탈퇴하기', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}