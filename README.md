📱 vipa (Virtual Intelligent Personalized Assistant)
vipa는 사용자 맞춤형 AI 기반 언어 학습 플랫폼입니다. AI 모델링과 옥스포드 사전을 결합하여 심도 있는 학습 경험을 제공하며, 모듈화된 구조를 통해 높은 확장성을 지향합니다.

🛠 Tech Stack
Framework: Flutter (Dart)

Architecture: Layered Feature-Based Architecture

State Management: Controller-based Logic Separation

External API: Oxford Dictionary API & AI Model Integration

📂 Project Structure
본 프로젝트는 기능(Feature)과 도메인(Domain) 단위로 모듈화되어 있으며, 파일 간 의존성을 최소화하고 재사용성을 극대화하도록 설계되었습니다.

Plaintext
lib/
├── main.dart                 # 앱 실행 진입점 (Entry Point)
├── constants/                # 앱 전반의 색상 테마 및 스타일 상수 관리
├── logic/                    # 비즈니스 로직 및 서버 통신 계층
│   ├── api_service.dart      # 베이스 네트워크 클라이언트
│   ├── home_controller.dart  # 상태 관리 및 제어 로직
│   └── oxford_api_service.dart # 외부 사전 API 연동
├── models/                   # 데이터 규격 및 모델링 (Type Safety)
├── routes/                   # 네비게이션 및 라우팅 전략 관리
└── screens/                  # 도메인별 독립적 UI 모듈
    ├── ai/                   # AI 학습 엔진 인터페이스
    ├── conversation/         # 대화형 학습 화면
    ├── grammar/              # 문법 교정 및 학습
    ├── history/              # 사용자 학습 이력 추적
    ├── home/                 # 메인 대시보드 및 위젯
    ├── vocabulary/           # 단어장 관리 시스템
    ├── login/
    │   └── login_screen.dart
    ├── mypage/
    │   └── mypage_screen.dart
    ├── signup/
    │   └── signup_screen.dart
    └── vocabulary/
        └── vocabulary_screen.dart


        
⚙️ Development Principles (Core Rules)
프로젝트의 지속 가능한 유지보수를 위해 다음의 원칙을 엄격히 준수합니다.

1. 코드 안정성 및 최적화
작성된 모든 코드는 정적 분석을 통해 성능 병목과 메모리 사용량을 점검합니다.

모듈 간의 의존성을 상시 확인하여 구조적 영향 평가를 실시합니다.

2. 자동화된 문서화
모든 함수와 클래스에는 로직 흐름, 변수 역할, 함수 기능에 대한 상세 주석을 유지합니다. (디버깅 시 삭제 금지)

파일 변경 및 구조 조정 시 전체 프로젝트 관점에서 Index와 README를 최신화합니다.

3. 일관된 코드 스타일
팀원 간 협업을 위해 네이밍 규칙 및 코드 스타일을 통일하고 자동 포매팅을 적용합니다.

4. 확장 중심 리팩토링
프로젝트 규모 확대 시 기능/화면/도메인 단위로 구조를 세분화하여 코드 복잡도를 제어합니다.

🚀 Key Features
AI-Powered Learning: 맞춤형 AI 모델을 통한 실시간 피드백 및 가이드.

Oxford Dict Integration: 공신력 있는 사전 데이터를 활용한 정확한 어휘 학습.

Progress Analytics: history 모듈을 통한 학습 데이터 추적 및 시각화.

Modular UI: 기능별로 분리된 Screen 설계를 통한 직관적인 사용자 경험.

📝 How to Run
Dependencies Installation:

Bash
flutter pub get
Run Application:

Bash
flutter run
📅 Version History
v1.0.0 - 초기 프로젝트 구조 설계 및 도메인별 모듈화 완료.

v1.1.0 - Oxford API 연동 로직 및 AI 화면 기초 설계 반영.

다음으로 이런 작업을 도와드릴까요?
logic/ 내의 주요 클래스들에 대한 코드 주석 템플릿을 만들어 드릴까요?

프로젝트의 기능 명세서(Functional Specification) 초안을 작성해 드릴까요?
