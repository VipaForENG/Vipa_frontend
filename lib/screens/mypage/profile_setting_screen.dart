import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/api_service.dart';
import '../login/auth_widgets.dart';

class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key, this.initialUserData});

  final Map<String, dynamic>? initialUserData;

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
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
    _nicknameController.text =
        userData?['nickname']?.toString() ?? 'Vipa 사용자';
    _profileImageUrl = userData?['profile_image']?.toString();
    _localProfileImagePath = userData?['local_profile_image_path']?.toString();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (image != null) setState(() => _selectedImage = image);
  }

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
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 58,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: const Text(
                    '프로필 수정',
                    style: TextStyle(
                      color: AuthColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(11, 15, 11, 30),
                  child: Column(
                    children: [
                      _SettingCard(
                        minHeight: 148,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '프로필 이미지',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 9),
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _buildProfileAvatar(),
                                  const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 11),
                      _SettingCard(
                        minHeight: 94,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(27, 11, 27, 19),
                          child: Column(
                            children: [
                              const Text(
                                '닉네임',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _nicknameController,
                                maxLength: 15,
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: '닉네임',
                                  hintStyle: const TextStyle(
                                    color: AuthColors.hint,
                                    fontSize: 12,
                                  ),
                                  filled: true,
                                  fillColor: AuthColors.input,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AuthColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 198,
                        height: 34,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AuthColors.primary,
                            disabledBackgroundColor: const Color(0xFFFF9A8A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(7),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  '이대로 변경!',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    Widget image = const SizedBox.shrink();
    if (_selectedImage != null) {
      image = Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        width: 90,
        height: 90,
      );
    } else if (_localProfileImagePath != null &&
        File(_localProfileImagePath!).existsSync()) {
      image = Image.file(
        File(_localProfileImagePath!),
        fit: BoxFit.cover,
        width: 90,
        height: 90,
      );
    } else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      image = Image.network(
        _profileImageUrl!,
        fit: BoxFit.cover,
        width: 90,
        height: 90,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    return CircleAvatar(
      radius: 45,
      backgroundColor: AuthColors.primary,
      child: ClipOval(child: SizedBox(width: 90, height: 90, child: image)),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.child, required this.minHeight});

  final Widget child;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
