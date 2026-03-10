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
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nickController = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('회원가입')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const Text("계정 만들기", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),

            // [위젯] 입력 필드들
            _buildTextField(_idController, "아이디"),
            _buildTextField(_pwController, "비밀번호", isObscure: true),
            _buildTextField(_emailController, "이메일"),
            _buildTextField(_nameController, "이름"),
            _buildTextField(_phoneController, "전화번호", keyboardType: TextInputType.phone),
            _buildTextField(_nickController, "닉네임"),

            const SizedBox(height: 30),

            // [위젯] 가입 완료 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // [로직] 여기서 컨트롤러 값들을 서버로 전송하는 로직을 구현합니다.
                  print("가입 시도: ${_idController.text}, ${_nickController.text}");
                  Navigator.pop(context);
                },
                child: const Text("가입 완료", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [함수] _buildTextField
  /// 목적: 중복되는 TextField 코드를 줄이기 위한 공통 위젯 생성 함수입니다.
  Widget _buildTextField(TextEditingController controller, String label,
      {bool isObscure = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}