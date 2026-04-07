import 'package:flutter/material.dart';

class VipaSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry; // 선언을 먼저 합니다.

    overlayEntry = OverlayEntry(
      builder: (context) => _MessageSnackBarWidget(
        message: message,
        isError: isError,
        // 애니메이션이 완전히 끝난 후 Overlay에서 제거하도록 콜백 전달
        onDismissed: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _MessageSnackBarWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismissed;

  const _MessageSnackBarWidget({
    required this.message,
    required this.isError,
    required this.onDismissed,
  });

  @override
  State<_MessageSnackBarWidget> createState() => _MessageSnackBarWidgetState();
}

class _MessageSnackBarWidgetState extends State<_MessageSnackBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // [수정 포인트] 좌표값을 더 직관적으로 조정
    // 화면 하단에서 위로 0.2(약 20%)만큼 올라온 지점에 멈춤
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.5),
      end: const Offset(0.0, -0.5),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // 2.5초 노출 후 reverse 애니메이션 실행
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (mounted) {
        await _controller.reverse(); // 애니메이션이 끝날 때까지 기다림
        widget.onDismissed(); // 그 다음 Overlay 제거
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SlideTransition(
          position: _offsetAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                // [수정 포인트] Vipa 프로젝트 표준 색상 적용 제안
                color: widget.isError
                    ? const Color(0xFFFF4757)
                    : const Color(0xFF2D3436),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
