import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'vocabulary_dashboard_provider.dart';
import '../../routes/app_routes.dart';

// ✨ [디자인 시스템 임포트]
import '../../design/background.dart'; 
import '../../design/animation_design.dart'; 

class VocabularyDashboardScreen extends StatefulWidget {
  const VocabularyDashboardScreen({super.key});

  @override
  State<VocabularyDashboardScreen> createState() => _VocabularyDashboardScreenState();
}

class _VocabularyDashboardScreenState extends State<VocabularyDashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VocabularyDashboardProvider>(context, listen: false).loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VocabularyDashboardProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // ✨ Appbar 뒤로 배경을 확장
      backgroundColor: Colors.white, // 바탕색은 하얀색
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 물결 배경(파란색 계열) 위에서 잘 보이도록 글씨 색상을 흰색으로!
        title: const Text('오늘의 어휘', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          // ✨ 대시보드에도 물결 배경 쫙 깔아주기!
          : Background(
              fillLevel: 0.25, // 화면 상단 25% 지점부터 찰랑거림
              child: _buildDashboardBody(provider, context),
            ),
    );
  }

  Widget _buildDashboardBody(VocabularyDashboardProvider provider, BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(), 
            
            // ✨ 가운데 원형 설정창이 아래에서 부드럽게 나타납니다!
            FadeSlideTransition(
              delay: 0.1,
              child: Container(
                width: 340, 
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 30, offset: const Offset(0, 15))
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("학습할 단어 설정", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 30), 
                    _buildAdjustableRow(provider, '새로운 단어', 'new', provider.chosenNew, provider.maxNew, Colors.blue),
                    const SizedBox(height: 10), 
                    _buildAdjustableRow(provider, '복습할 단어', 'review', provider.chosenReview, provider.maxReview, Colors.orange),
                    const SizedBox(height: 10),
                    _buildAdjustableRow(provider, '재도전 단어', 'retry', provider.chosenRetry, provider.maxRetry, Colors.redAccent),
                  ],
                ),
              ),
            ),
            
            const Spacer(),

            // 하단 학습 시작 버튼
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (provider.chosenNew == 0 && provider.chosenReview == 0 && provider.chosenRetry == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("학습할 단어를 1개 이상 선택해주세요!")));
                        return;
                      }

                      // 퀴즈 화면(vocabulary)으로 이동
                      Navigator.pushNamed(
                        context, 
                        AppRoutes.vocabulary, // 🌟 이 경로는 app_routes.dart에 맞춰주세요! (vocabulary 또는 grammar)
                        arguments: {
                          'new_count': provider.chosenNew,
                          'review_count': provider.chosenReview,
                          'retry_count': provider.chosenRetry,
                        }
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7B61FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
                    ),
                    child: const Text('오늘의 학습하기', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAdjustableRow(VocabularyDashboardProvider provider, String label, String type, int currentVal, int maxVal, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.grey), onPressed: () => provider.adjustCount(type, -1)),
              SizedBox(
                width: 60,
                child: Text('$currentVal / $maxVal', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: accentColor)),
              ),
              IconButton(icon: Icon(Icons.add_circle, color: accentColor), onPressed: () => provider.adjustCount(type, 1)),
            ],
          ),
        ],
      ),
    );
  }
}