// screens/changepw/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../routes/app_routes.dart';

class ChangePasswordScreen extends StatefulWidget {
  final bool isFromMyPage;
  const ChangePasswordScreen({super.key, this.isFromMyPage = false});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confirmPwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.isFromMyPage ? "비밀번호 수정" : "새 비밀번호 설정", 
             style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              const Text("안전한 비밀번호로 변경해 주세요.", style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 50),

              _buildUnderlineField(_pwController, "새 비밀번호", RemixIcons.lock_password_line),
              const SizedBox(height: 25),
              _buildUnderlineField(_confirmPwController, "새 비밀번호 확인", RemixIcons.checkbox_circle_line),
              
              const SizedBox(height: 50),

              SizedBox(
                width: 300,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: 비밀번호 변경 API 호출
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("비밀번호 변경이 완료되었습니다.")),
                    );
                    
                    if (widget.isFromMyPage) {
                      Navigator.pop(context);
                    } else {
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text("변경 완료", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnderlineField(TextEditingController controller, String hint, IconData icon) {
    return SizedBox(
      width: 300,
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 35),
          hintText: hint,
          enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black87, width: 2)),
        ),
      ),
    );
  }
}