import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/api_service.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key, this.initialUserData});

  final Map<String, dynamic>? initialUserData;

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  static const _primaryColor = Color(0xFFFF4F39);
  static const _pageBackground = Color(0xFFF2F2F2);

  final TextEditingController _nicknameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _profileImageUrl;
  String? _localProfileImagePath;
  XFile? _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> _pickImage() async {
    // 갤러리에서 선택한 이미지는 먼저 로컬 상태에 보관해 저장 전 미리보기에 사용한다.
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (image == null) return;
    setState(() => _selectedImage = image);
  }

  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.length < 2 || nickname.length > 15) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('닉네임은 2~15자로 입력해주세요.')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      // 닉네임과 선택한 이미지 경로를 함께 전송해 프로필 정보를 한 번에 수정한다.
      final updatedUser = await ApiService.updateMyProfile(
        nickname: nickname,
        imagePath: _selectedImage?.path,
      );
      if (_selectedImage != null) {
        // 서버 이미지 반영 전에도 방금 선택한 사진이 보이도록 로컬 경로를 캐시에 저장한다.
        updatedUser['local_profile_image_path'] = _selectedImage!.path;
        await GetStorage().write(
          'local_profile_image_path',
          _selectedImage!.path,
        );
      }

      await GetStorage().write('user_data', updatedUser);

      if (!mounted) return;
      Navigator.pop(context, updatedUser);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('프로필이 변경되었습니다.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('프로필 변경 실패: $e')));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
              children: [
                _ProfileTitle(onBack: () => Navigator.pop(context)),
                const SizedBox(height: 8),
                _ShadowPanel(
                  height: 140,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '프로필 이미지',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _buildProfileImage(),
                            const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _ShadowPanel(
                  height: 108,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(42, 19, 42, 16),
                    child: Column(
                      children: [
                        const Text(
                          '닉네임',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 11),
                        TextField(
                          controller: _nicknameController,
                          maxLength: 15,
                          textAlignVertical: TextAlignVertical.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: '닉네임',
                            hintStyle: const TextStyle(
                              color: Color(0xFFB7BAC3),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF3F4F7),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(
                                color: _primaryColor,
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                SizedBox(
                  height: 42,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      disabledBackgroundColor: _primaryColor.withValues(
                        alpha: 0.65,
                      ),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      _isSaving ? '변경 중...' : '마이페이지 변경하기',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    Widget fallback = const ColoredBox(
      color: _primaryColor,
      child: SizedBox(width: 76, height: 76),
    );

    Widget image = fallback;
    if (_selectedImage != null) {
      image = Image.file(File(_selectedImage!.path), fit: BoxFit.cover);
    } else if (_localProfileImagePath != null &&
        _localProfileImagePath!.isNotEmpty &&
        File(_localProfileImagePath!).existsSync()) {
      image = Image.file(File(_localProfileImagePath!), fit: BoxFit.cover);
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      image = Image.network(
        _profileImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      );
    }

    return ClipOval(child: SizedBox(width: 76, height: 76, child: image));
  }
}

class _ProfileTitle extends StatelessWidget {
  const _ProfileTitle({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            '프로필 수정',
            style: TextStyle(
              color: _ProfileSettingScreenState._primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          Positioned(
            left: 0,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new, size: 17),
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShadowPanel extends StatelessWidget {
  const _ShadowPanel({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
