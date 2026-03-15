📱 vipa (Virtual Intelligent Personalized Assistant)
vipa는 사용자 맞춤형 AI 기반 언어 학습 플랫폼입니다. AI 모델링과 옥스포드 사전을 결합하여 심도 있는 학습 경험을 제공하며, 모듈화된 구조를 통해 높은 확장성을 지향합니다.

🛠 Tech Stack
Framework: Flutter (Dart)

Architecture: Layered Feature-Based Architecture

State Management: Controller-based Logic Separation

External API: Oxford Dictionary API & AI Model Integration

📂 Project Structure
본 프로젝트는 기능(Feature)과 도메인(Domain) 단위로 모듈화되어 있으며, 파일 간 의존성을 최소화하고 재사용성을 극대화하도록 설계되었습니다.

lib/
├── api/                            # API 통신 및 데이터 컨트롤러
│   ├── api_service.dart            # 공통 API 서비스
│   ├── home_controller.dart        # 홈 화면 로직 제어
│   └── oxford_api_service.dart     # 옥스퍼드 사전 API 서비스
│
├── design/                         # 공통 디자인 위젯 및 시스템
│   ├── button_design.dart          # 버튼 스타일 정의
│   ├── card_design.dart            # 카드 레이아웃 정의
│   ├── circle_design.dart          # 원형 요소 디자인
│   ├── section_header.dart         # 섹션 타이틀 헤더
│   └── snack_bar.dart              # 커스텀 VipaSnackBar
│
├── models/                         # 데이터 모델링
│   └── word_quiz_model.dart        # 단어 퀴즈 데이터 규격
│
├── routes/                         # 네비게이션 관리
│   └── app_routes.dart             # 라우팅 경로 및 맵 정의
│
├── screens/                        # 도메인별 화면 모듈
│   ├── ai/                         # AI 대화 엔진 관련
│   │   ├── widgets/
│   │   │   └── voice_wave.dart     # 음성 파형 애니메이션
│   │   └── ai_screen.dart          # AI 메인 화면
│   │
│   ├── changepw/                   # 비밀번호 관리
│   │   └── change_password_screen.dart
│   │
│   ├── conversation/               # 실전 회화 학습
│   │   ├── widgets/
│   │   │   └── conversation_widgets.dart
│   │   ├── conversation_provider.dart
│   │   └── conversation_screen.dart
│   │
│   ├── history/                    # 학습 이력
│   │   └── learning_history_screen.dart
│   │
│   ├── home/                       # 홈 대시보드
│   │   ├── widgets/
│   │   │   ├── attendance_section.dart
│   │   │   ├── learning_chart_section.dart
│   │   │   ├── quick_menu_section.dart
│   │   │   └── user_profile_section.dart
│   │   └── home_screen.dart
│   │
│   ├── login/                      # 인증 및 로그인
│   │   ├── login_screen.dart
│   │   └── reset_password_screen.dart
│   │
│   ├── mypage/                     # 사용자 설정 및 구독
│   │   ├── mypage_screen.dart
│   │   ├── profile_setting_screen.dart
│   │   ├── subscription_history_screen.dart
│   │   └── subscription_screen.dart
│   │
│   └── signup/                     # 회원가입
│       └── signup_screen.dart
│
└── main.dart                       # 앱 시작점


        
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
