import 'package:flutter/material.dart';
import 'conversation_provider.dart';

class EvaluationDetailView extends StatelessWidget {
  final ConversationProvider provider;

  const EvaluationDetailView({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. 스크롤 가능한 내용 영역
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Evaluation Result",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildPassBadge(provider.feedbackKo),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "Your Answer:",
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  Text(
                    "\"${provider.userSpokenText}\"",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(color: Colors.white10),
                  ),
                  const Text(
                    "AI Feedback:",
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                  Text(
                    provider.feedbackKo,
                    style: const TextStyle(
                      color: Color(0xFFB3A9FF),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildRecommendedBox(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 2. 고정 버튼 영역
          Row(
            children: [
              _actionButton(
                Icons.refresh,
                "Retry",
                false,
                () => provider.setAnswered(false),
              ),
              const SizedBox(width: 10),
              _actionButton(Icons.arrow_forward, "Next", true, () {
                provider.nextStep();
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPassBadge(String feedback) {
    bool isPass =
        feedback.contains("완벽") ||
        feedback.contains("좋아") ||
        feedback.contains("훌륭");
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPass
            ? Colors.greenAccent.withValues(alpha: 0.2)
            : Colors.orangeAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPass ? "PASS" : "NEED REVIEW",
        style: TextStyle(
          color: isPass ? Colors.greenAccent : Colors.orangeAccent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRecommendedBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recommended Sentence:",
            style: TextStyle(
              color: Colors.greenAccent,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            provider.correctedEn,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    IconData icon,
    String label,
    bool isPrimary,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isPrimary
                ? const Color(0xFF8877FF)
                : Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
