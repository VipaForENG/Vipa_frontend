import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart'; // RemixIcon 패키지 확인 필요
import '../../routes/app_routes.dart'; // 현재 프로젝트 라우트
import '../../Design/snack_bar.dart'; // 기존 프로젝트의 스낵바 디자인
import '../../controllers/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  bool _isLoading = false; // 로딩 상태 추가

  /// [함수] _handleLogin 연동 버전
  Future<void> _handleLogin() async {
    final email = _idController.text.trim();
    final password = _pwController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      VipaSnackBar.show(context, '이메일과 비밀번호를 모두 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    // AuthController를 통한 API 호출
    final result = await AuthController.login(email: email, password: password);

    setState(() => _isLoading = false);

    if (result != null) {
      // 1. 토큰 저장 로직 (필요 시 추가)
      // String token = result['access_token'];

      // 2. 성공 피드백 및 이동
      if (!mounted) return;
      VipaSnackBar.show(context, '성공적으로 로그인되었습니다!');
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // 3. 실패 피드백
      if (!mounted) return;
      VipaSnackBar.show(context, '이메일 또는 비밀번호가 일치하지 않습니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 228, 173),
      // 키보드가 올라올 때 화면이 가려지지 않도록 설정
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 95),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // 이미지 모서리를 둥글게
                  child: Image.network(
                    'https://cdn.discordapp.com/attachments/1482731178753654865/1491120727976443994/LOGO-Photoroom.png?ex=69d689e5&is=69d53865&hm=0e97e775c1ae8a46e987be819ef1f600daecbc86c9e51ce0073a328f141e72bf&', // 임시 이미지 링크
                    width: 100, // 이미지 너비
                    height: 100, // 이미지 높이
                    fit: BoxFit.cover,
                    // 이미지 로딩 중 표시할 위젯 (선택사항)
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        width: 100,
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    // 이미지 로드 실패 시 표시할 위젯
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 100,
                      height: 100,
                      color: const Color(0xFFEDF0F3),
                      child: const Icon(
                        Icons.broken_image,
                        color: Colors.black26,
                      ),
                    ),
                  ),
                ),

                // 로고 섹션
                const Text(
                  'VIPA',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 216, 154),
                    fontSize: 45,
                    fontWeight: FontWeight.w900, // 기존 1000 대신 w900 사용
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 60),

                // 이메일 입력 필드
                _buildUnderlineTextField(
                  controller: _idController,
                  hintText: '이메일',
                  icon: RemixIcons.mail_fill,
                ),
                const SizedBox(height: 20),

                // 비밀번호 입력 필드
                _buildUnderlineTextField(
                  controller: _pwController,
                  hintText: '비밀번호',
                  icon: RemixIcons.lock_password_fill,
                  isObscure: true,
                ),
                const SizedBox(height: 40),

                // 로그인 버튼
                _buildPrimaryButton(
                  text: _isLoading ? '로그인 중...' : '로그인', // 로딩 텍스트 대응
                  onPressed: _isLoading ? () {} : _handleLogin, // 로딩 중 클릭 방지
                  color: Colors.black87,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 30),

                // 구글 로그인
                _buildPrimaryButton(
                  text: '구글로 로그인',
                  onPressed: _handleLogin, // 현재는 개발용이라 같은 함수 연결
                  color: Colors.white,
                  textColor: Colors.black87,
                  hasBorder: true,
                ),
                const SizedBox(height: 10),

                // 카카오 로그인
                _buildPrimaryButton(
                  text: '카카오로 로그인',
                  onPressed: _handleLogin,
                  color: const Color(0xFFFEE500),
                  textColor: Colors.black87,
                ),

                const SizedBox(height: 20),

                // 하단 보조 버튼 (회원가입, 비밀번호 찾기)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.signup),
                      child: const Text(
                        '회원가입',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                    const Text('|', style: TextStyle(color: Colors.black12)),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, AppRoutes.resetPassword),
                      child: const Text(
                        '비밀번호 찾기',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- 위젯 분리 ---

  // 다른 프로젝트 스타일의 언더라인 텍스트 필드
  Widget _buildUnderlineTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isObscure = false,
  }) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black12, width: 1),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.black87, width: 2),
          ),
        ),
      ),
    );
  }

  // 버튼 공통 위젯
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    required Color color,
    required Color textColor,
    bool hasBorder = false,
  }) {
    return SizedBox(
      width: 300,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: hasBorder
                ? const BorderSide(color: Colors.black87)
                : BorderSide.none,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
