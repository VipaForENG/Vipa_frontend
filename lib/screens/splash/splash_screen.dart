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
    return const Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF512F),
              Color(0xFFF09819),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 고해상도 로고 이미지
                Image(
                  image: AssetImage('assets/images/splash_logo.png'),
                  width: 240,
                  height: 240,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
                SizedBox(height: 34),
                // 메인 타이틀
                Text(
                  '최고의 영어회화 학습어플',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}