import 'package:flutter/material.dart';

/// [클래스] SignupScreen
/// 목적: 아이디, 비밀번호, 이메일, 이름, 전화번호, 닉네임을 입력받아 회원가입을 처리합니다.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // [컨트롤러] 각 입력 필드별 데이터 관리를 위한 컨트롤러
  bool _isPasswordVisible = false;
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nickController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // [디자인] 상단 안내 문구
              const Text(
                "새로운 시작을 위해\n정보를 입력해주세요",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 40),

              // [위젯] 각 입력 필드들 (커스텀 함수 호출)
              _buildModernTextField(
                controller: _idController,
                label: "아이디",
                hint: "사용하실 아이디를 입력하세요",
                icon: Icons.person_outline,
              ),
              _buildModernTextField(
                controller: _pwController,
                label: "비밀번호",
                hint: "비밀번호를 입력하세요",
                icon: Icons.lock_outline,
                isObscure: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
              ),
              _buildModernTextField(
                controller: _emailController,
                label: "이메일",
                hint: "example@vipa.com",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              _buildModernTextField(
                controller: _nameController,
                label: "이름",
                hint: "실명을 입력하세요",
                icon: Icons.badge_outlined,
              ),
              _buildModernTextField(
                controller: _phoneController,
                label: "전화번호",
                hint: "010-0000-0000",
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
              _buildModernTextField(
                controller: _nickController,
                label: "닉네임",
                hint: "앱에서 사용할 이름을 입력하세요",
                icon: Icons.face_outlined,
              ),

              const SizedBox(height: 40),

              // [위젯] 가입 완료 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // [로직] 나중에 여기서 서버 통신(api_service.dart 활용)을 구현합니다.
                    print("가입 시도 아이디: ${_idController.text}");
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Vipa 테마 컬러
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "가입 완료",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// [함수] _buildModernTextField
  /// 목적: 중복 코드를 방지하고 통일된 디자인의 입력창을 생성합니다.
  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isObscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            prefixIcon: Icon(icon, color: Colors.blueAccent, size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}