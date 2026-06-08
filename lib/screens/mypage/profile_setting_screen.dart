import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/api_service.dart';
import '../../design/app_colors.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key, this.initialUserData});

  final Map<String, dynamic>? initialUserData;

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  // --- 상태 데이터 ---
  final TextEditingController _nicknameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String? _profileImageUrl;
  String? _localProfileImagePath;
  XFile? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 초기 데이터 설정: 전달받은 데이터가 없으면 로컬 스토리지에서 읽음
    final userData = widget.initialUserData ?? GetStorage().read('user_data');
    _nicknameController.text = userData?['nickname']?.toString() ?? '';
    _profileImageUrl = userData?['profile_image']?.toString();
    _localProfileImagePath = userData?['local_profile_image_path']?.toString();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // --- 비즈니스 로직 ---

  /// 갤러리에서 이미지 선택 (품질 및 사이즈 최적화)
  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (image == null) return;
    setState(() => _selectedImage = image);
  }

  /// 프로필 저장 프로세스 (API 통신 및 로컬 캐시 업데이트)
  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.length < 2 || nickname.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('닉네임은 2~15자로 입력해주세요.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // API 호출: 닉네임과 이미지 변경 사항 전송
      final updatedUser = await ApiService.updateMyProfile(
        nickname: nickname,
        imagePath: _selectedImage?.path,
      );

      // 로컬 이미지 경로 캐싱 (즉시 반영을 위해)
      if (_selectedImage != null) {
        updatedUser['local_profile_image_path'] = _selectedImage!.path;
        await GetStorage().write('local_profile_image_path', _selectedImage!.path);
      }

      // 전체 유저 데이터 로컬 업데이트
      await GetStorage().write('user_data', updatedUser);

      if (!mounted) return;
      Navigator.pop(context, updatedUser); // 변경된 데이터를 이전 화면으로 전달
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로필이 변경되었습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('프로필 변경 실패: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- UI 구현 ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("프로필 설정", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("완료", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // 프로필 이미지 영역
            Center(
              child: Stack(
                children: [
                  _buildProfileAvatar(),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),

            // 닉네임 입력 필드
            _buildInputLabel("닉네임"),
            TextField(
              controller: _nicknameController,
              maxLength: 15,
              decoration: InputDecoration(
                hintText: "변경할 닉네임을 입력하세요",
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            const Text("특수문자를 제외한 2~15자 이내로 입력해주세요.", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  /// 프로필 이미지를 렌더링하는 위젯 (로컬/네트워크/선택된 이미지 우선순위 처리)
  Widget _buildProfileAvatar() {
    Widget imageWidget = const Icon(Icons.person, size: 80, color: Colors.blueAccent);

    // 1. 방금 갤러리에서 선택한 이미지 우선
    if (_selectedImage != null) {
      imageWidget = Image.file(File(_selectedImage!.path), fit: BoxFit.cover, width: 120, height: 120);
    } 
    // 2. 이전에 로컬에 저장된 이미지
    else if (_localProfileImagePath != null && File(_localProfileImagePath!).existsSync()) {
      imageWidget = Image.file(File(_localProfileImagePath!), fit: BoxFit.cover, width: 120, height: 120);
    }
    // 3. 서버에서 받아온 이미지
    else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      imageWidget = Image.network(_profileImageUrl!, fit: BoxFit.cover, width: 120, height: 120, errorBuilder: (_, __, ___) => imageWidget);
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
      child: ClipOval(child: SizedBox(width: 120, height: 120, child: imageWidget)),
    );
  }

  Widget _buildInputLabel(String label) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }
}