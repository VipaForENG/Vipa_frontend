import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // 1600ms 후 로그인 화면으로 이동
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      Get.offNamed(AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF9A12), Color(0xFFFF4F39)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/vipa_logo_mark.png',
                width: 108,
                height: 104,
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                    letterSpacing: -0.2,
                  ),
                  children: [
                    TextSpan(text: '최고의 '),
                    TextSpan(
                      text: '영어회화',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    TextSpan(text: ' 학습어플'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
