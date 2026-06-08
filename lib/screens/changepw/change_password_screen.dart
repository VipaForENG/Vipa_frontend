import 'package:flutter/material.dart';
import '../../controllers/auth_controller.dart';
import '../../design/snack_bar.dart';
import '../../routes/app_routes.dart';
import '../login/auth_widgets.dart';

/// [모듈 설명] 비밀번호 변경 및 재설정 화면을 담당하는 위젯입니다.
/// 마이페이지를 통한 비밀번호 변경 흐름과, 로그인 외부에서 비밀번호 찾기(이메일 인증)를 통한 재설정 흐름을 동시에 지원합니다.
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key, this.isFromMyPage = false});

  /// [상태] 마이페이지 진입 여부 플래그 (true일 경우 라우트 인자 검증을 건너뛰고 이전 화면으로 복귀)
  final bool isFromMyPage;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  /// [메모리] 새 비밀번호 입력을 위한 컨트롤러. 무조건 dispose 필요.
  final TextEditingController _passwordController = TextEditingController();
  
  /// [메모리] 새 비밀번호 확인 입력을 위한 컨트롤러.
  final TextEditingController _confirmPasswordController = TextEditingController();

  /// [상태] API 통신 중 버튼 중복 클릭 및 인디케이터 제어를 위한 로딩 상태
  bool _isLoading = false;
  
  /// [상태] 각 필드의 실시간/제출 시점 유효성 검증 에러 메시지
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    // [성능/메모리] 컨트롤러 인스턴스 해제하여 메모리 누수 방지
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// [함수 역할] 정규식을 활용하여 소문자, 숫자, 특수문자가 포함된 8자 이상의 비밀번호인지 검증합니다.
  bool _isPasswordValid(String password) {
    return RegExp(
      r'^(?=.*[a-z])(?=.*[0-9])(?=.*[!@#$%^&*(),.?":{}|<>]).{8,}$',
    ).hasMatch(password);
  }

  /// [함수 역할] 입력 데이터를 최종 검증하고 백엔드 API에 비밀번호 변경을 요청합니다.
  /// [로직 흐름] 에러 초기화 ➡️ 유효성 검사 ➡️ 일치 검사 ➡️ 인자 확인 ➡️ API 호출 ➡️ 라우팅 복귀
  Future<void> _handleResetPassword() async {
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // 상태 초기화
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // 1. 비밀번호 복잡도 정적 검증
    if (!_isPasswordValid(password)) {
      setState(() => _passwordError = '소문자, 숫자, 특수문자 조합(8자 이상)이 필요합니다.');
      return;
    }

    // 2. 비밀번호 일치 여부 확인 (Feature 브랜치 누수 로직 보완)
    if (password != confirmPassword) {
      setState(() => _confirmPasswordError = '비밀번호가 일치하지 않습니다.');
      return;
    }

    // 3. 이전 화면에서 전달받은 Arguments 꺼내기 (이메일 인증 토큰 정보 복구)
    final args = ModalRoute.of(context)?.settings.arguments;
    
    // [안전성] 타입 캐스팅 에러(TypeError)를 방지하기 위해 as 형태가 아닌 safe-cast 처리
    final recoveryArgs = args is Map<String, dynamic> ? args : null;

    // 외부 비밀번호 찾기 흐름인데 인증 인자가 누락된 경우의 방어 코드
    if (recoveryArgs == null && !widget.isFromMyPage) {
      VipaSnackBar.show(context, '잘못된 접근입니다.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // 4. 인증 컨트롤러를 통한 비밀번호 변경 API 수행
    final success = await AuthController.resetPassword(
      email: recoveryArgs?['email'] as String? ?? '',
      code: recoveryArgs?['code'] as String? ?? '',
      newPassword: password,
    );

    // [안전성] 비동기 처리 중 위젯이 언마운트 되었을 경우 setState 호출 차단
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!success) {
      VipaSnackBar.show(
        context,
        '비밀번호 변경에 실패했습니다. 코드가 만료되었을 수 있습니다.',
        isError: true,
      );
      return;
    }

    // 5. 성공 후 라우팅 흐름 분기
    if (widget.isFromMyPage) {
      // 마이페이지 內 변경은 기존 서비스 유지하므로 루트 화면으로 복귀
      VipaSnackBar.show(context, '비밀번호 변경이 완료되었습니다.');
      Navigator.popUntil(context, (route) => route.isFirst);
      return;
    }

    // 외부 비밀번호 분실 재설정은 로그인 화면으로 전송 및 스택 클리어
    VipaSnackBar.show(context, '비밀번호 변경이 완료되었습니다. 다시 로그인해주세요.');
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // [스타일 점검] 통일된 인증 레이아웃 템플릿(AuthScaffold) 구조 통합 적용
    return AuthScaffold(
      child: Column(
        children: [
          const SizedBox(height: 91),
          Text(
            widget.isFromMyPage ? '비밀번호 수정' : '비밀번호 변경해 주세요!',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.05,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '새롭게 사용할 비밀번호를 작성해주세요!',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 75),
          
          // 새 비밀번호 입력 필드
          AuthTextField(
            controller: _passwordController,
            label: '비밀번호 입력',
            hintText: '비밀번호',
            obscureText: true,
            errorText: _passwordError,
            onChanged: (_) => setState(() => _passwordError = null),
          ),
          const SizedBox(height: 14),
          
          // 비밀번호 확인 입력 필드
          AuthTextField(
            controller: _confirmPasswordController,
            label: '비밀번호 확인',
            hintText: '비밀번호 확인',
            obscureText: true,
            errorText: _confirmPasswordError,
            onChanged: (_) => setState(() => _confirmPasswordError = null),
          ),
          const SizedBox(height: 31),
          
          // 최종 제출 버튼
          AuthButton(
            text: _isLoading ? '변경 중...' : '비밀번호 변경',
            onPressed: _isLoading ? null : _handleResetPassword,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}