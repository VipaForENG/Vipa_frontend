import 'package:flutter/material.dart';

/// [클래스] ProfileSettingScreen
/// 사용자의 프로필 사진과 닉네임을 변경하는 화면입니다.
class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  // 닉네임 입력을 관리하는 컨트롤러 (초기값 설정)
  final TextEditingController _nicknameController = TextEditingController(text: "Vipa 사용자");

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 컨트롤러 해제
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "프로필 설정",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // 뒤로가기 버튼 커스텀
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 저장 버튼
          TextButton(
            onPressed: () {
              // TODO: 서버에 변경된 닉네임과 이미지 저장하는 API 연결
              debugPrint("새로운 닉네임: ${_nicknameController.text}");
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("프로필이 변경되었습니다.")),
              );
            },
            child: const Text(
              "완료",
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // [섹션 1] 프로필 이미지 변경 영역
            Center(
              child: Stack(
                children: [
                  // 프로필 배경 원형
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, size: 80, color: Colors.blueAccent),
                  ),
                  // 카메라 아이콘 버튼
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: () {
                        // TODO: 이미지 피커(Image Picker) 라이브러리 연결 예정
                        debugPrint("이미지 수정 클릭");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // [섹션 2] 닉네임 입력 필드
            _buildInputLabel("닉네임"),
            TextField(
              controller: _nicknameController,
              maxLength: 15, // 최대 글자 수 제한
              decoration: InputDecoration(
                hintText: "변경할 닉네임을 입력하세요",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                // 포커스 되었을 때 테두리
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            const Text(
              "특수문자를 제외한 2~15자 이내로 입력해주세요.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// [함수] 입력 필드 위에 붙는 작은 라벨
  Widget _buildInputLabel(String label) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }
}