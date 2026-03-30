# 📱 VIPA Frontend (Flutter)

**VIPA**는 영어 학습을 돕는 스마트한 보조 도구입니다. 이 리포지토리는 Flutter로 구현된 사용자 인터페이스와 백엔드 통신 로직을 포함하고 있습니다.

---

## ✨ 주요 기능 (Key Features)

- **실시간 유효성 검사**: 회원가입 시 이메일 형식, 비밀번호 규칙, 닉네임 길이를 실시간으로 체크합니다.
- **백엔드 API 연동**: `Dio` 라이브러리를 사용하여 커스텀 백엔드 서버와 데이터를 주고받습니다.
- **현대적인 UI/UX**: `RemixIcon`과 세련된 언더라인 스타일의 입력 필드를 적용했습니다.

## 📂 프로젝트 구조 (Directory Roles)

```text
lib/
├── api/                # ApiService (Dio 설정 및 BaseURL 관리)
├── controllers/        # AuthController 등 비즈니스 로직 제어
├── Design/             # 공통 UI 컴포넌트 (SnackBar, CustomButton 등)
├── routes/             # AppRoutes (화면 전환 경로 정의)
└── screens/            # 각 기능별 화면 (Login, Signup 등)
```

## 🛠️ 기술 스택 (Tech Stack)
- Framework: Flutter (Dart)
- Network: Dio
- Icons: RemixIcon
- State Management: StatefulWidget & SetState (기초 단계)

## 🚀 시작하기 (Getting Started)
1. 환경 설정 Flutter SDK가 설치되어 있어야 합니다. (추천 버전: 3.19.0 이상)
2. 의존성 설치프로젝트 루트에서 아래 명령어를 입력하여 필요한 패키지를 다운로드합니다.
   ```Bash
   flutter pub get
   ```
4. API 서버 연결 설정lib/api/api_service.dart 파일에서 본인의 백엔드 서버 IP 주소로 수정해야 합니다.
   ```Dart
   static const String baseUrl = "http://YOUR_SERVER_IP:8000/api/v1";
   ```
   
6. 앱 실행
   ```Bash
   flutter run
   ```
