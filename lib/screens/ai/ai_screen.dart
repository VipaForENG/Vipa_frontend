import 'package:flutter/material.dart';
import 'package:remixicon/remixicon.dart';
import '../../design/animation_design.dart'; 
import '../../controllers/ai_controller.dart';
import 'widgets/voice_wave.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final AiController _controller = AiController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF5E4AD);
    const Color waveColor = Color(0xFFFFF9E3);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'VIPA TALK',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: WaveBackground(
              waveColor: waveColor,
              waveHeightFactor: 0.4,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  // 2. AI 응답 영역 (글래스모피즘 카드)
                  Expanded(
                    flex: 6,
                    child: FadeSlideTransition(
                      delay: 0.2,
                      child: _buildGlassCard(
                        child: _controller.isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: Colors.black87),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center( // 🔥 내용이 짧을 땐 수직 중앙 정렬 유지
                                  child: SingleChildScrollView( // 🔥 내용이 넘치면 스크롤 허용
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min, // 🔥 Column이 자식 크기만큼만 팽창하도록 제한
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(RemixIcons.robot_2_line, color: Colors.blueAccent, size: 30),
                                        const SizedBox(height: 20),
                                        
                                        // 🇺🇸 영어 발화
                                        Text(
                                          _controller.aiEnText,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF2D3436),
                                            height: 1.3,
                                          ),
                                        ),
                                        
                                        const SizedBox(height: 15),
                                        
                                        // 🇰🇷 한국어 번역
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_controller.aiFeedback.isNotEmpty && _controller.aiFeedback != "N/A")
                    FadeSlideTransition(
                      delay: 0.4,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          // 🔥 [수정] withOpacity -> withValues(alpha: ...)
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            // 🔥 [수정] withOpacity -> withValues(alpha: ...)
                            color: Colors.orangeAccent.withValues(alpha: 0.5), 
                            width: 1.5
                          ),
                          boxShadow: [
                            // 🔥 [수정] withOpacity -> withValues(alpha: ...)
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(RemixIcons.lightbulb_flash_line, color: Colors.orange),
                            const SizedBox(width: 12),
                            Expanded(
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

                  Expanded(
                    flex: 3,
                    child: FadeSlideTransition(
                      delay: 0.6,
                      child: _buildGlassCard(
                        opacity: 0.4,
                        child: Center(
                          child: VoiceWaveView(
                            onTextRecognized: (text) {
                              _controller.sendToAi(text);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child, double opacity = 0.6}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // 🔥 [수정] withOpacity -> withValues(alpha: ...)
        color: Colors.white.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          // 🔥 [수정] withOpacity -> withValues(alpha: ...)
          color: Colors.white.withValues(alpha: 0.4), 
          width: 1.2
        ),
        boxShadow: [
          BoxShadow(
            // 🔥 [수정] withOpacity -> withValues(alpha: ...)
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            spreadRadius: 5,
          )
        ],
      ),
      child: child,
    );
  }
}