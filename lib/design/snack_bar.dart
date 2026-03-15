import 'package:flutter/material.dart';

class VipaSnackBar {
  static void show(BuildContext context, String message, {bool isError = false}) {
    // Overlay를 사용하여 화면 최상단에 위젯을 직접 띄웁니다.
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _MessageSnackBarWidget(
        message: message,
        isError: isError,
      ),
    );

    // 화면에 추가
    overlay.insert(overlayEntry);

    // 2.5초 후에 제거
    Future.delayed(const Duration(milliseconds: 2500), () {
      overlayEntry.remove();
    });
  }
}

class _MessageSnackBarWidget extends StatefulWidget {
  final String message;
  final bool isError;

  const _MessageSnackBarWidget({required this.message, required this.isError});

  @override
  State<_MessageSnackBarWidget> createState() => _MessageSnackBarWidgetState();
}

class _MessageSnackBarWidgetState extends State<_MessageSnackBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    // [애니메이션 설정] 0.5초 동안 부드럽게 작동
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 시작 위치는 화면 밖(아래), 도착 위치는 원래 자리
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 2.0),
      end: const Offset(0.0, -2.0), // 살짝 위로 띄움
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // 쫀득하게 올라오는 효과
    ));

    _controller.forward(); // 시작

    // 사라질 때 애니메이션
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) _controller.reverse();
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
                color: widget.isError ? Colors.redAccent : Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Text(
                widget.message,
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}