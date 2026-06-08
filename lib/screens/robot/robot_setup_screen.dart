import 'package:flutter/material.dart';
import '../../design/card_design.dart';
import '../../design/app_colors.dart'; // 기존 카드 디자인 위젯 활용

class RobotSetupScreen extends StatefulWidget {
  const RobotSetupScreen({super.key});

  @override
  State<RobotSetupScreen> createState() => _RobotSetupScreenState();
}

class _RobotSetupScreenState extends State<RobotSetupScreen> {
  // 로직을 위한 상태 변수들
  final TextEditingController _ipController = TextEditingController();
  bool _isConnected = true; // 현재 연결됨 상태 가정
  double _energyLevel = 0.7; // 로봇 에너지 (0.0 ~ 1.0)
  String _statusMessage = "상태 양호"; // 생존 상태 메시지

  @override
  void dispose() {
    _ipController.dispose(); // 메모리 누수 방지를 위한 컨트롤러 해제
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          '로봇 설정 및 제어',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        // 하단 탭바에서 접근할 때는 뒤로가기 버튼이 자동으로 생깁니다.
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIPInputSection(), // 1. IP 입력
            const SizedBox(height: 20),
            _buildStatusSection(), // 2. 연결 상태 및 에너지
            const SizedBox(height: 30),
            const Text(
              "하드웨어 테스트 및 제어",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            _buildFaceTestSection(), // 3. 표정 테스트 (오버플로 수정 적용)
            const SizedBox(height: 20),
            _buildMotorControlSection(), // 4. 모터 영점 조절 (유연한 레이아웃 적용)
            const SizedBox(height: 20),
            _buildSoundCheckSection(), // 5. 사운드 체크
          ],
        ),
      ),
    );
  }

  // 1. 로봇 IP 입력 섹션
  Widget _buildIPInputSection() {
    return cardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "로봇의 IP를 입력해주세요.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ipController,
            decoration: InputDecoration(
              hintText: "IP는 로봇의 뒷면에 적혀 있습니다....",
              hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  child: const Text("연결"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("취소"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. 상태 인디케이터 및 에너지 섹션
  Widget _buildStatusSection() {
    return Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 8,
              backgroundColor: _isConnected ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 10),
            Text(
              _isConnected ? "현재 연결됨" : "연결 안 됨",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            const Text("로봇의 에너지  "),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: _energyLevel,
                  minHeight: 15,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            '"$_statusMessage"',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // 3. 표정 테스트 섹션 (⚠️ 오버플로 수정 완료)
  Widget _buildFaceTestSection() {
    return Row(
      children: [
        const Text("표정 테스트 : "),
        // 💡 해결책: 남은 공간에서 가로 스크롤이 가능하도록 Expanded + SingleChildScrollView 조합
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _faceButton("(^▽^)"),
                _faceButton("(o.o;)"),
                _faceButton("(-_-;)"),
                // 버튼이 추가되어도 이제 화면이 깨지지 않습니다.
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _faceButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: Colors.black,
          minimumSize: const Size(60, 36), // 버튼 최소 크기 지정으로 일관성 유지
        ),
        onPressed: () {
          debugPrint("표정 전송: $label");
        },
        child: Text(label),
      ),
    );
  }

  // 4. 모터 영점 조절 섹션
  Widget _buildMotorControlSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("모터 영점 조절", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _motorRow("위아래"),
        _motorRow("좌우"),
      ],
    );
  }

  Widget _motorRow(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 50, child: Text(label)),
            ElevatedButton(onPressed: () {}, child: const Text("내리기")),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text("각도 : ? 도"),
            ),
            ElevatedButton(onPressed: () {}, child: const Text("올리기")),
          ],
        ),
      ),
    );
  }

  // 5. 사운드 체크 섹션
  Widget _buildSoundCheckSection() {
    return Row(
      children: [
        const Text("사운드 체크: "),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            debugPrint("사운드 테스트 시작");
          },
          child: const Text("테스트 버튼"),
        ),
      ],
    );
  }
}
