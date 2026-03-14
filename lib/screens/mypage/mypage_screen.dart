import 'package:flutter/material.dart';
import '../changepw/change_password_screen.dart';
import '../mypage/profile_setting_screen.dart'; // [추가] 실제 화면 연결을 위해 임포트
import '../../routes/app_routes.dart';

/// [클래스] MyPageScreen
/// 사용자님의 기존 로직에 Vipa의 UI 개선사항을 통합한 버전입니다.
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String loginType = 'email'; 

    return Scaffold(
      // [개선] 배경색을 연한 회색으로 설정하여 흰색 카드들이 더 입체적으로 보이게 함
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
            // [섹션 1] 프로필 요약 카드
            _buildProfileCard(context),
            const SizedBox(height: 30),

            // [섹션 2] 내 정보 관리 메뉴
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
              _buildMenuItem(
                icon: Icons.person_remove_outlined, 
                title: '회원 탈퇴', 
                onTap: () => _showWithdrawalDialog(context), 
                isDanger: true, // [개선] 위험 버튼임을 명시하여 빨간색으로 렌더링
              ),
            ]),

            const SizedBox(height: 30),
            
            // [섹션 3] 로그아웃 버튼
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  /// [함수] _buildProfileCard
  /// [변경사항] 
  /// 1. withOpacity 대신 최신 문법 withValues(alpha: 0.05) 사용 (Lint 경고 해결)
  /// 2. 프로필 수정 버튼 클릭 시 ProfileSettingScreen으로 이동하는 로직 추가
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            // [수정] Flutter 최신 버전의 투명도 설정 방식 적용
            color: Colors.black.withValues(alpha: 0.05), 
            blurRadius: 10, 
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
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
          // [수정] 실제 '프로필 설정' 화면으로 이동하도록 Navigator 연결
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
    );
  }

  /// [함수] _buildMenuCard
  /// [변경사항] 불필요한 null 필터링 제거 (입력받은 children 리스트를 그대로 사용)
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

  /// [함수] _buildMenuItem
  /// [변경사항] 호출 시 '이름 있는 인자(named parameters)'를 사용하여 가독성 향상
  Widget _buildMenuItem({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap, 
    bool isDanger = false, // 탈퇴 버튼 등 강조용
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

  /// [함수] _buildSectionTitle
  /// 메뉴 그룹 위의 회색 작은 제목
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
  /// 로그아웃 시 로그인 페이지로 이동 (라우트 사용)
  Widget _buildLogoutButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
      icon: const Icon(Icons.logout, color: Colors.grey),
      label: const Text('로그아웃', style: TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }

  /// [함수] _showWithdrawalDialog
  /// 사용자님의 기존 탈퇴 확인 로직 유지
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