import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../api/api_service.dart';
import '../../design/app_colors.dart'; // 팀원의 공통 디자인 시스템 임포트 적용

/// 사용자 프로필(닉네임, 아바타 이미지)을 수정하고 서버 및 로컬 캐시에 동기화하는 설정 화면
class ProfileSettingScreen extends StatefulWidget {
  const ProfileSettingScreen({super.key, this.initialUserData});

  /// 이전 화면(마이페이지 등)에서 전달받은 초기 사용자 데이터
  final Map<String, dynamic>? initialUserData;

  @override
  State<ProfileSettingScreen> createState() => _ProfileSettingScreenState();
}

class _ProfileSettingScreenState extends State<ProfileSettingScreen> {
  // --- 상태 관리 및 폼 컨트롤러 ---
  
  /// 닉네임 입력을 관리하는 텍스트 컨트롤러
  final TextEditingController _nicknameController = TextEditingController();
  
  /// 디바이스 갤러리 접근을 위한 이미지 피커 인스턴스
  final ImagePicker _picker = ImagePicker();
  
  /// 원격 서버에 저장된 기존 프로필 이미지 URL
  String? _profileImageUrl;
  
  /// 디바이스 로컬에 캐싱된 이전 프로필 이미지 경로 (빠른 렌더링용)
  String? _localProfileImagePath;
  
  /// 사용자가 갤러리에서 새로 선택한 이미지 객체
  XFile? _selectedImage;
  
  /// API 통신 중복 호출을 막기 위한 로딩 상태 플래그
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  @override
  void dispose() {
    // 메모리 누수(Memory Leak) 방지를 위해 컨트롤러 자원 해제
    _nicknameController.dispose();
    super.dispose();
  }

  /// [비즈니스 로직] 초기 데이터 바인딩
  /// 상위 위젯에서 데이터를 넘겨받지 못한 경우 GetStorage에서 안전하게 Fallback 처리
  void _initializeUserData() {
    final userData = widget.initialUserData ?? GetStorage().read('user_data');
    _nicknameController.text = userData?['nickname']?.toString() ?? 'Vipa 사용자';
    _profileImageUrl = userData?['profile_image']?.toString();
    _localProfileImagePath = userData?['local_profile_image_path']?.toString();
  }

  /// [비즈니스 로직] 디바이스 갤러리에서 이미지 픽업 및 리사이징 최적화
  Future<void> _pickImage() async {
    // 메모리 사용량 최적화 및 업로드 병목을 줄이기 위해 품질과 최대 크기 제한 (OOM 방지)
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1024,
    );

    if (image == null) return;
    setState(() => _selectedImage = image);
  }

  /// [비즈니스 로직] 프로필 정보 저장 및 전역 캐시 업데이트
  Future<void> _saveProfile() async {
    final nickname = _nicknameController.text.trim();
    
    // 유효성 검사: 닉네임 길이 제한 (API 에러 사전 차단)
    if (nickname.length < 2 || nickname.length > 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임은 2~15자로 입력해주세요.')),
      );
      return;
    }

    // 중복 제출 방지 락(Lock) 설정
    setState(() => _isSaving = true);

    try {
      // 1. API 호출: 서버에 닉네임 및 이미지 변경 사항 전송
      final updatedUser = await ApiService.updateMyProfile(
        nickname: nickname,
        imagePath: _selectedImage?.path,
      );

      // 2. 로컬 이미지 경로 캐싱 (마이페이지로 돌아갔을 때 즉시 반영시키기 위함 - HEAD 로직 유지)
      if (_selectedImage != null) {
        updatedUser['local_profile_image_path'] = _selectedImage!.path;
        await GetStorage().write('local_profile_image_path', _selectedImage!.path);
      }

      // 3. 전역 유저 데이터 로컬 업데이트
      await GetStorage().write('user_data', updatedUser);

      // 4. 비동기 작업 후 컨텍스트 유효성 검증 (안전성)
      if (!mounted) return;
      
      // 마이페이지에 변경된 데이터를 리턴하며 화면 종료
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
      // 저장 완료 후 로딩 락 해제
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // --- UI 컴포넌트 빌더 ---

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
          // [UI] 저장 중일 때 로딩 인디케이터 표시, 아닐 경우 완료 버튼 (팀원 UI 포매팅 적용)
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

            // [섹션 1] 프로필 이미지 렌더링 및 수정 영역
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
            
            // [섹션 2] 닉네임 입력 폼 영역
            _buildInputLabel('닉네임'),
            TextField(
              controller: _nicknameController,
              maxLength: 15,
              decoration: InputDecoration(
                hintText: "변경할 닉네임을 입력하세요",
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
              "특수문자를 제외한 2~15자 이내로 입력해주세요.", 
              style: TextStyle(fontSize: 12, color: Colors.grey)
            ),
          ],
        ),
      ),
    );
  }

  /// [UI 헬퍼] 프로필 이미지를 렌더링 (로컬/네트워크/선택된 이미지 우선순위 판별)
  /// HEAD의 로컬 캐시 처리 로직을 살려, 깜빡임(Flicker) 현상과 불필요한 네트워크 비용을 줄임.
  Widget _buildProfileAvatar() {
    Widget imageWidget = const Icon(Icons.person, size: 80, color: Colors.blueAccent);

    // 1순위: 방금 갤러리에서 선택한 이미지 (가장 최신)
    if (_selectedImage != null) {
      imageWidget = Image.file(File(_selectedImage!.path), fit: BoxFit.cover, width: 120, height: 120);
    } 
    // 2순위: 이전에 로컬에 저장(캐시)된 파일이 존재하는 경우
    else if (_localProfileImagePath != null && File(_localProfileImagePath!).existsSync()) {
      imageWidget = Image.file(File(_localProfileImagePath!), fit: BoxFit.cover, width: 120, height: 120);
    }
    // 3순위: 서버에서 받아온 원격 이미지 (폴백 처리 포함)
    else if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      imageWidget = Image.network(
        _profileImageUrl!, 
        fit: BoxFit.cover, 
        width: 120, 
        height: 120, 
        errorBuilder: (_, __, ___) => imageWidget
      );
    }

    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.blueAccent.withValues(alpha: 0.1),
      child: ClipOval(child: SizedBox(width: 120, height: 120, child: imageWidget)),
    );
  }

  /// [UI 헬퍼] 입력 폼 상단의 라벨 텍스트 렌더링
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