import 'package:flutter/material.dart';

class ConversationResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const ConversationResultScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF263238), Color(0xFF1E1E2C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 🏆 성취 아이콘
              _buildSuccessIcon(),

              const SizedBox(height: 24),

              // 🎉 완료 메시지
              Text(
                result['message'] ?? "학습을 완료했습니다!",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),

              const Spacer(flex: 1),

              // 📊 학습 리포트 카드
              _buildReportCard(),

              const Spacer(flex: 2),

              // 🏠 홈으로 돌아가기 버튼
              _buildHomeButton(context),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF8877FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.emoji_events_rounded,
        color: Color(0xFF8877FF),
        size: 85,
      ),
    );
  }

  Widget _buildReportCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildInfoRow("학습자", result['nickname'] ?? "사용자"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: Colors.white10),
          ),
          _buildInfoRow("학습 상황", result['situation_title'] ?? "일반 대화"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(color: Colors.white10),
          ),
          _buildInfoRow(
            "AI 교정 문장",
            "${result['corrected_count'] ?? 0}개",
            isHighlight: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 16),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? const Color(0xFF8877FF) : Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8877FF),
          minimumSize: const Size(double.infinity, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        onPressed: () {
          Navigator.pop(context); // 목록으로 돌아가기
        },
        child: const Text(
          "목록으로 돌아가기",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
