# VIPA · AI 영어 학습 앱

**레벨 테스트부터 맞춤 회화·어휘 학습·학습 기록까지 연결한 Flutter 앱입니다.**

2학년 1학기 융합프로젝트 실습에서 제작한 팀 프로젝트입니다. FastAPI 백엔드에서 받은 문제·시나리오·평가 결과를 화면에 표시하고, 음성 또는 텍스트로 영어 학습을 진행할 수 있도록 구성했습니다.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=flat-square&logo=android&logoColor=white)
![Dio](https://img.shields.io/badge/Dio-5A29E4?style=flat-square)

| 구분 | 내용 |
| :--- | :--- |
| 개발 형태 | 대학 수업 팀 프로젝트 |
| 프론트엔드 | **[송민창](https://github.com/Onin0782)** · UI·Flutter 화면 구현 및 API 연동 |
| 백엔드·DB | **[엄유준](https://github.com/EddieEom)** · DB 설계 및 백엔드 전체 개발 |
| 초기 구성 | 엄유준이 프론트엔드 초기 구조 구성 |
| 연결 확인 | 앱에서 레벨 테스트·결과 조회·결과 기반 맞춤 시나리오 및 회화 동작 확인 |

[백엔드 저장소](https://github.com/VipaForENG/Vipa_backend)

## 실행 화면

<table>
<tr><th width="50%">① 레벨 테스트</th><th width="50%">② 평가 결과</th></tr>
<tr>
<td align="center"><img src="https://raw.githubusercontent.com/EddieEom/EddieEom/main/assets/screenshots/vipa-test.jpg" alt="CEFR 레벨 테스트 문제 화면" width="240"/></td>
<td align="center"><img src="https://raw.githubusercontent.com/EddieEom/EddieEom/main/assets/screenshots/vipa-result.jpg" alt="B1 레벨 판정과 학습 피드백 화면" width="240"/></td>
</tr>
<tr><th>③ 맞춤 시나리오 생성</th><th>④ 실전 회화</th></tr>
<tr>
<td align="center"><img src="https://raw.githubusercontent.com/EddieEom/EddieEom/main/assets/screenshots/vipa-scenario.jpg" alt="선택한 상황의 회화 시나리오 생성 화면" width="240"/></td>
<td align="center"><img src="https://raw.githubusercontent.com/EddieEom/EddieEom/main/assets/screenshots/vipa-conversation.jpg" alt="음성으로 진행하는 실전 회화 화면" width="240"/></td>
</tr>
</table>

## 주요 기능

| 기능 | 앱에서 제공하는 내용 |
| :--- | :--- |
| 로그인·계정 | 이메일·Google·Kakao 로그인, 프로필, 비밀번호 관리 |
| 레벨 테스트 | 서버에서 받은 문제 표시, 답안 제출, CEFR 결과·피드백 조회 |
| 자유 회화 | 음성·텍스트 입력, AI 답변·한국어 번역 표시, 영어 문장 듣기 |
| 실전 회화 | 상황 선택, 맞춤 시나리오, 답변 평가·교정, 단계별 힌트 |
| 어휘 학습 | 신규·복습·재도전 학습량 선택, 문제 풀이, 힌트·즐겨찾기 |
| 학습 기록 | 회화 이력·오답·즐겨찾기 조회, 녹음 재생, 회화 PDF 공유 |
| 홈 | 학습 에너지·진행률·출석·학습 요약 표시 |

## 화면과 데이터를 연결한 방식

### 사용자 상태에 맞는 화면 이동

로그인 응답의 테스트 완료 여부를 확인해 레벨 테스트 또는 홈으로 이동합니다. 학습을 마치고 홈으로 돌아오면 요약 API를 다시 요청해 변경된 학습 상태를 표시합니다.

### 인증·통신 처리 공통화

`ApiService`에서 Dio 인스턴스를 관리합니다. JWT는 `FlutterSecureStorage`에 저장하고, 요청 인터셉터에서 인증 헤더에 추가합니다. 인증 만료를 나타내는 401 응답도 공통으로 처리하도록 구성했습니다.

### 음성과 텍스트 입력 지원

`speech_to_text`로 영어 발화를 문자로 변환하고, 키보드 입력으로 전환할 수 있도록 했습니다. AI가 반환한 영어 문장은 `flutter_tts`로 다시 들을 수 있습니다.

### 학습 진행 상태 관리

Provider·GetX를 활용해 로딩, 현재 회화 턴, 힌트 단계, 문제 번호와 학습 결과를 화면에 반영합니다. 즐겨찾기는 화면을 먼저 변경한 뒤 요청하고, 실패하면 이전 상태로 되돌립니다.

## 시스템 구성

| 구성 요소 | 역할 |
| :--- | :--- |
| Flutter 화면 | 사용자 입력·문제·대화·결과 표시 |
| Provider·Controller | 화면 상태와 학습 진행 관리 |
| Dio·ApiService | FastAPI 요청, 인증 헤더, 응답·오류 처리 |
| FastAPI 백엔드 | 인증·학습 데이터·AI 요청·기록 저장 |

<details>
<summary><b>화면 구성과 사용 패키지</b></summary>

| 화면 영역 | 주요 내용 |
| :--- | :--- |
| 로그인·가입 | 이메일·소셜 로그인, 비밀번호 재설정 |
| 레벨 테스트 | 문제·답안·결과 화면 |
| 홈 | 학습 요약, 진행률, 학습 기능 진입 |
| 회화 | 상황 선택, 음성·텍스트 대화, 평가·힌트 |
| 어휘 | 학습량 설정, 문제·재도전·결과 |
| 학습 이력 | 대화·오답·즐겨찾기, 녹음 재생·PDF 공유 |
| 마이페이지 | 프로필·이미지·비밀번호·계정 관리 |

| 목적 | 패키지 |
| :--- | :--- |
| 상태 관리 | `provider`, `get` |
| API 통신 | `dio` |
| 토큰·로컬 저장 | `flutter_secure_storage`, `get_storage` |
| 소셜 로그인 | `google_sign_in`, `kakao_flutter_sdk` |
| 음성 입력·출력 | `speech_to_text`, `flutter_tts`, `permission_handler` |
| 이미지·오디오 | `image_picker`, `just_audio` |
| PDF·공유 | `pdf`, `printing`, `share_plus`, `path_provider` |
| 차트·기타 | `fl_chart`, `flutter_dotenv`, `intl` |

</details>

<details>
<summary><b>코드 구성</b></summary>

| 경로 | 역할 |
| :--- | :--- |
| `lib/screens/` | 기능별 화면 |
| `lib/controllers/` | 상태·기능 제어 |
| `lib/models/` | API 응답 데이터 모델 |
| `lib/api/` | 서버 주소·공통 API 처리 |
| `lib/services/` | 인증·음성 등 기능 처리 |
| `lib/routes/` | 화면 경로 관리 |
| `lib/design/` | 공통 색상·디자인 |
| `lib/main.dart` | 앱 시작과 초기화 |

학습 화면의 상호작용은 Provider·ChangeNotifier, 일부 화면의 상태와 생명주기는 GetX Controller로 관리합니다.

공통 색상과 테마를 적용하고 기본 글꼴은 Pretendard를 사용합니다. 화면별 API 응답은 모델로 변환해 상태와 UI에 반영합니다.

</details>

<details>
<summary><b>설치 및 실행</b></summary>

### 1. 개발 환경과 의존성 준비

Flutter SDK와 Android 개발 환경을 준비합니다.

```bash
git clone https://github.com/VipaForENG/Vipa_frontend.git
cd Vipa_frontend
flutter doctor
flutter pub get
```

### 2. 환경변수 설정

프로젝트 루트에 `.env`를 작성합니다.

```env
KAKAO_NATIVE_APP_KEY=YOUR_KAKAO_NATIVE_APP_KEY
GOOGLE_WEB_CLIENT_ID=YOUR_GOOGLE_WEB_CLIENT_ID
```

소셜 로그인을 사용하려면 각 서비스의 앱 등록·플랫폼 설정도 실행 환경에 맞춰 준비합니다.

### 3. 백엔드 연결

`lib/api/api_config.dart`에서 `isLocal`과 서버 주소를 확인합니다.

| 실행 환경 | API 주소 |
| :--- | :--- |
| Android 에뮬레이터에서 로컬 서버 사용 | `http://10.0.2.2:8000/api/v1` |
| 같은 PC에서 로컬 서버 사용 | `http://127.0.0.1:8000/api/v1` |
| 배포 서버 사용 | 설정된 배포 주소 사용 |

실제 Android 기기는 개발 PC의 LAN 주소 등 기기에서 접근 가능한 서버 주소를 사용해야 합니다. 로컬 백엔드 준비 방법은 [백엔드 README](https://github.com/VipaForENG/Vipa_backend)를 참고합니다.

### 4. 앱 실행

```bash
flutter run
```

Android 최소 SDK는 24로 설정되어 있습니다. 음성 기능은 마이크 권한과 기기의 음성 인식·TTS 환경을 확인합니다.

</details>
