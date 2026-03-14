import 'package:flutter/material.dart';
import '../changepw/change_password_screen.dart';
import '../../routes/app_routes.dart'; // 경로 상수를 위해 추가

/// [클래스] MyPageScreen
/// 목적: 사용자 프로필, 계정 관리, 로그아웃 기능을 포함한 마이페이지 화면.
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // [가정] 실제 개발 시에는 서버나 상태 관리에서 사용자 정보를 가져옵니다.
    const String loginType = 'email'; 

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
            _buildProfileCard(),
            const SizedBox(height: 30),

            _buildSectionTitle('내 정보 관리'),
            _buildMenuCard([
              if (loginType == 'email')
                _buildMenuItem(
                  Icons.lock_outline,
                  '비밀번호 변경',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ChangePasswordScreen(isFromMyPage: true),
                      ),
                    );
                  },
                ),
              _buildMenuItem(Icons.email_outlined, '이메일 변경', () => debugPrint("이메일 변경 시도")),
              _buildMenuItem(
                Icons.person_remove_outlined, 
                '회원 탈퇴', 
                () => _showWithdrawalDialog(context), 
                isDanger: true
              ),
            ]),

            const SizedBox(height: 30),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  /// [함수] _buildProfileCard
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // [수정] deprecated: withOpacity -> withValues 사용
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4)
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35, 
            backgroundColor: Colors.blueAccent, 
            child: Icon(Icons.person, color: Colors.white, size: 40)
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
          OutlinedButton(onPressed: () {}, child: const Text('프로필 수정')),
        ],
      ),
    );
  }

  /// [함수] _buildMenuCard
  Widget _buildMenuCard(List<Widget> children) {
    // [수정] unnecessary_null_comparison 경고 해결을 위해 필터링 제거 (이미 Widget 타입임이 보장됨)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(children: children),
    );
  }

  /// [함수] _buildMenuItem
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : Colors.blueAccent),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDanger ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  /// [함수] _buildSectionTitle
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 5),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
      ),
    );
  }

  /// [함수] _buildLogoutButton
  Widget _buildLogoutButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
      icon: const Icon(Icons.logout, color: Colors.grey),
      label: const Text('로그아웃', style: TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }

  /// [함수] _showWithdrawalDialog
  void _showWithdrawalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text('회원 탈퇴', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            '정말로 VIPA를 떠나시겠어요?\n탈퇴 시 모든 학습 데이터와 단어장이 삭제되며 복구할 수 없습니다.',
            style: TextStyle(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                // [로직] 실제 서버 탈퇴 API 연동 예정
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