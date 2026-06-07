import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/api_service.dart';
import '../../design/app_colors.dart'; // 팀원의 디자인 시스템 임포트

class ProfileSettingScreen extends StatefulWidget {
  final Map<String, dynamic>? initialUserData;

  const ProfileSettingScreen({super.key, this.initialUserData});

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  // [로직] main의 컨트롤러 및 상태 변수 유지
  final TextEditingController _nicknameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _profileImageUrl;
  XFile? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // [로직] GetStorage에서 유저 정보 불러오기
    final userData = widget.initialUserData ?? GetStorage().read('user_data');
    _nicknameController.text = userData?['nickname']?.toString() ?? 'Vipa 사용자';
    _profileImageUrl = userData?['profile_image']?.toString();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  // [로직] 갤러리에서 이미지 픽업
  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (image == null) return;
    setState(() => _selectedImage = image);
  }

  // [로직] 백엔드에 프로필 정보 저장
  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.length < 2 || nickname.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임은 2~15자로 입력해주세요.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedUser = await ApiService.updateMyProfile(
        nickname: nickname,
        imagePath: _selectedImage?.path,
      );
      
      if (_selectedImage != null) {
        updatedUser['local_profile_image_path'] = _selectedImage!.path;
        await GetStorage().write('local_profile_image_path', _selectedImage!.path);
      }

      await GetStorage().write('user_data', updatedUser);

      if (!mounted) return;
      Navigator.pop(context, updatedUser);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필이 변경되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('프로필 변경 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // [UI] 팀원의 AppColors 및 AppBar 스타일 적용
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '프로필 설정',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // [UI + 로직] 완료 버튼에 저장 중(_isSaving) 상태 로직 입히기
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    '완료',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // [섹션 1] 프로필 이미지 변경 영역 (팀원의 UI + _buildProfileImage 로직)
            Center(
              child: Stack(
                children: [
                  _buildProfileImage(),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: GestureDetector(
                      onTap: _pickImage, // 로직 연결
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
            
            // [섹션 2] 닉네임 입력 영역
            _buildInputLabel('닉네임'),
            TextField(
              controller: _nicknameController,
              maxLength: 15,
              decoration: InputDecoration(
                hintText: '변경할 닉네임을 입력하세요.',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
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
            const Text(
              '닉네임은 2~15자 이내로 입력해주세요.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

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

  // [로직] main의 이미지 렌더링 로직 (네트워크 폴백 포함) 유지
  Widget _buildProfileImage() {
    Widget fallback = Container(
      color: Colors.blueAccent.withValues(alpha: 0.1),
      child: const Icon(Icons.person, size: 80, color: Colors.blueAccent),
    );

    Widget image = fallback;
    if (_selectedImage != null) {
      image = Image.file(File(_selectedImage!.path), fit: BoxFit.cover);
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      image = Image.network(
        _profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return ClipOval(child: SizedBox(width: 120, height: 120, child: image));
  }
}