import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../design/animation_design.dart';
import '../../design/app_colors.dart';
import '../../controllers/ai_controller.dart';
import '../login/auth_widgets.dart';
import 'widgets/voice_wave.dart';

/// [모듈 설명] AI 프리토킹 화면을 담당하는 메인 스크린 위젯.
/// 사용자의 음성/텍스트 입력을 받아 AI와 실시간으로 영어 대화를 나누는 핵심 도메인 화면입니다.
class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  /// [의존성] AI 통신 및 상태 관리를 전담하는 비즈니스 로직 컨트롤러
  final AiController _controller = AiController();
  
  /// [메모리] 텍스트 입력 시트에서 사용할 컨트롤러. 메모리 누수 방지를 위해 dispose 필수.
  final TextEditingController _textController = TextEditingController();
  
  /// [상태] 사용자가 발화를 시작했는지 여부를 추적하여 초기 안내 문구 등을 제어하는 상태 변수
  // bool _hasStartedTalking = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  /// [함수 역할] 컨트롤러 상태가 변경될 때 호출되어 UI를 동적으로 리렌더링합니다.
  void _onControllerChanged() {
    // [안전성] 위젯 트리에서 해제된 상태(unmounted)에서 setState가 호출되는 것을 방지
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    // [성능/메모리] 메모리 누수(Memory Leak) 방지를 위해 리스너 해제 및 컨트롤러 필수 폐기
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  /// [함수 역할] 글래스모피즘(Glassmorphic) 스타일의 투명 카드를 생성하는 공통 UI 빌더
  /// [로직 흐름] 투명도(opacity)를 인자로 받아 배경과 테두리의 블러 효과를 동적으로 렌더링합니다.
  Widget _buildGlassCard({required Widget child, double opacity = 0.7}) {
    return Container(
      decoration: BoxDecoration(
        // [스타일 점검] 최신 Flutter 스펙에 맞춘 withValues(alpha: ...) 사용
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // [변수 사용] 웨이브 애니메이션에 전달할 전역 테마 색상 로드
    const Color waveColor = AppColors.wave;

    return Scaffold(
      // [로직] 배경 웨이브 애니메이션이 상단 상태바/AppBar 영역까지 자연스럽게 침투하도록 설정
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: const Text(
          'AI프리토킹',
          style: TextStyle(
            color: AuthColors.primary,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // [UI 영역] 1. 다이내믹 웨이브 배경 레이어
          Positioned.fill(
            child: WaveBackground(waveColor: waveColor, waveHeightFactor: 0.4),
          ),

          // [UI 영역] 2. 메인 컨텐츠 레이어
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // [UI 영역] 3. AI 응답 출력 영역 (상단 글래스모피즘 카드)
                  Expanded(
                    flex: 6,
                    child: FadeSlideTransition(
                      delay: 0.2,
                      child: _buildGlassCard(
                        // [로직] 컨트롤러가 로딩 중이면 프로그레스 인디케이터 노출, 아니면 대화 내용 노출
                        child: _controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.black87,
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: SingleChildScrollView(
                                    // [안전성] 텍스트가 화면 높이를 초과할 경우 픽셀 오버플로우 방지
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          RemixIcons.robot_2_line,
                                          color: Colors.blueAccent,
                                          size: 30,
                                        ),
                                        const SizedBox(height: 20),

                                        // [UI 영역] 🇺🇸 AI 영어 발화 텍스트 렌더링
                                        Text(
                                          _controller.aiEnText.isEmpty 
                                              ? "AI와 대화를 시작해보세요!" 
                                              : _controller.aiEnText,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2D3436),
                                            height: 1.3,
                                          ),
                                        ),
                                        
                                        // [로직] 한국어 번역 가이드가 존재할 경우에만 렌더링
                                        if (_controller.aiKoText.isNotEmpty) ...[
                                          const SizedBox(height: 15),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(alpha: 0.05),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _controller.aiKoText,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black87.withValues(alpha: 0.7),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // [UI 영역] 4. 문법 교정 피드백 영역
                  // [로직] AI로부터 받은 피드백 데이터가 존재하고 N/A가 아닐 때만 동적으로 레이아웃에 추가
                  if (_controller.aiFeedback.isNotEmpty && _controller.aiFeedback != "N/A")
                    FadeSlideTransition(
                      delay: 0.4,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.orangeAccent.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              RemixIcons.lightbulb_flash_line,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              // [안전성] 텍스트가 길어질 때 줄바꿈 처리를 위해 Expanded로 감쌈
                              child: Text(
                                _controller.aiFeedback,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // [UI 영역] 5. 음성 인식 및 하단 조작 영역
                  Expanded(
                    flex: 3,
                    child: FadeSlideTransition(
                      delay: 0.6,
                      child: _buildGlassCard(
                        opacity: 0.4,
                        child: Center(
                          // [의존성] VoiceWaveView 위젯 호출. 인식된 텍스트를 콜백으로 받아온다.
                          child: VoiceWaveView(
                            onTextRecognized: (text) {
                              if (text.trim().isNotEmpty) {
                               
                                _controller.sendToAi(text.trim());
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // [UI 영역] 키보드 텍스트 입력을 활성화하는 버튼
                  TextButton.icon(
                    onPressed: _openTextSheet,
                    icon: const Icon(Icons.keyboard_alt_outlined, color: Color(0xFFFF907D)),
                    label: const Text(
                      '텍스트로 입력하기',
                      style: TextStyle(color: Color(0xFFFF907D), fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// [함수 역할] 텍스트 입력을 위한 모달 바텀 시트를 화면에 띄웁니다.
  void _openTextSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // [안전성] 키보드 활성화 시 시트가 위로 밀려나도록 설정하여 가림 현상 방지
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            // [UI 조정] viewInsetsOf를 활용해 기기 키보드 높이만큼 동적으로 패딩을 부여
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20, 
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    autofocus: true,
                    cursorColor: AuthColors.primary,
                    decoration: InputDecoration(
                      hintText: '영어로 말할 내용을 입력하세요',
                      filled: true,
                      fillColor: AuthColors.input,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AuthColors.primary),
                      ),
                    ),
                    onSubmitted: (_) => _sendTypedMessage(context),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: () => _sendTypedMessage(context),
                  style: IconButton.styleFrom(
                    backgroundColor: AuthColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// [함수 역할] 입력된 텍스트 메시지를 검증하고 AI 컨트롤러로 전송합니다.
  void _sendTypedMessage(BuildContext sheetContext) {
    final text = _textController.text.trim();
    if (text.isEmpty) return; // [성능] 빈 문자열 전송 방지
    
    _textController.clear();
    Navigator.pop(sheetContext); // [로직] 메시지 전송 후 시트 닫기
    // setState(() => _hasStartedTalking = true);
    _controller.sendToAi(text);
  }
}