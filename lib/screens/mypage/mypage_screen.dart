import 'package:flutter/material.dart';

/// [클래스] MyPageScreen
/// 목적: 사용자 프로필, 계정 관리, 로그아웃 기능을 포함한 마이페이지 화면.
class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // 배경색을 은은한 회색으로 변경하여 카드 강조
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
            // [위젯] 상단 프로필 카드 (스케치 이미지의 상단부 반영)
            _buildProfileCard(),
            const SizedBox(height: 30),

            // [위젯] 내 정보 관리 섹션 (스케치 하단 메뉴 반영)
            _buildSectionTitle('내 정보 관리'),
            _buildMenuCard([
              _buildMenuItem(Icons.lock_outline, '비밀번호 변경', () => print("비번변경")),
              _buildMenuItem(Icons.email_outlined, '이메일 변경', () => print("이메일변경")),
              _buildMenuItem(Icons.person_remove_outlined, '회원 탈퇴', () => print("탈퇴"), isDanger: true),
            ]),

            const SizedBox(height: 30),

            // [위젯] 로그아웃 버튼 (하단 강조)
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  /// [함수] _buildProfileCard
  /// 목적: 프로필 사진, 닉네임, 이메일을 담은 카드 형태의 위젯 생성.
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 35, backgroundColor: Colors.blueAccent, child: Icon(Icons.person, color: Colors.white, size: 40)),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
  /// 목적: 메뉴 항목들을 감싸는 카드 배경 생성.
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
  /// 목적: 개별 메뉴 행 구성 (아이콘, 텍스트, 클릭 이벤트).
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      leading: Icon(icon, color: isDanger ? Colors.red : Colors.blueAccent),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500, color: isDanger ? Colors.red : Colors.black87)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  /// [함수] _buildSectionTitle
  /// 목적: 섹션 구분용 제목 텍스트 구성.
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
  /// 목적: 화면 하단에 배치할 로그아웃 버튼 구성.
  Widget _buildLogoutButton() {
    return TextButton.icon(
      onPressed: () => print("로그아웃"),
      icon: const Icon(Icons.logout, color: Colors.grey),
      label: const Text('로그아웃', style: TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }
}