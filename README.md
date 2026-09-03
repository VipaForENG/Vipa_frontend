# 🇺🇸 VIPA Frontend

<div align="center">

### CEFR-based AI English Learning Mobile Application

**사용자의 영어 수준에 맞춰
AI 자유 회화 · 실전 시나리오 · 어휘 학습 · 학습 기록을 제공하는 Flutter 기반 영어 학습 애플리케이션입니다.**

<br>

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge\&logo=dart\&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge\&logo=android\&logoColor=white)
![Google](https://img.shields.io/badge/Google%20Sign--In-4285F4?style=for-the-badge\&logo=google\&logoColor=white)
![Kakao](https://img.shields.io/badge/Kakao%20Login-FFCD00?style=for-the-badge\&logo=kakao\&logoColor=000000)

</div>

<br>

---

# 📌 Project Overview

**VIPA**는 사용자의 영어 수준을 CEFR 기준으로 분석하고,
분석된 수준에 맞는 영어 학습 경험을 제공하는 AI 기반 영어 학습 애플리케이션입니다.

이 저장소는 VIPA 서비스의 **Flutter Mobile Client**이며,

* 회원가입 / 로그인
* Google / Kakao Social Login
* CEFR Level Test
* AI Free Talking
* AI Scenario Conversation
* Speech Recognition
* Text-to-Speech
* Vocabulary Learning
* Learning History
* Conversation Review
* PDF Export / Share
* User Profile

등의 사용자 인터페이스와 Backend API 연동을 담당합니다.

### Backend Repository

👉 [VIPA Backend](https://github.com/VipaForENG/Vipa_backend)

<br>

---

# 👨‍💻 Frontend Developer

### 송민창

**GitHub**
https://github.com/Onin0782

**Role — Frontend Development**

VIPA의 Flutter Mobile Client 구현과
Backend API를 사용자 인터페이스와 연결하는 역할을 담당했습니다.

주요 Frontend 영역:

* Flutter UI / UX 구현
* 화면 Navigation 구성
* REST API Integration
* JWT Authentication Flow
* Google / Kakao Social Login 연동
* Provider / GetX 기반 상태 관리
* AI Conversation UI
* Speech-to-Text
* Text-to-Speech
* Scenario Learning UI
* Vocabulary Learning UI
* Learning History UI
* Profile Management
* PDF Export / Share

<br>

---

# 🔄 Application Flow

```text
App Start
   │
   ▼
Splash
   │
   ▼
Login / Sign Up
   │
   ├── Email Login
   ├── Google Login
   └── Kakao Login
           │
           ▼
      Level Test 여부
        │       │
       No      Yes
        │       │
        ▼       │
   CEFR Test    │
        │       │
        └───┬───┘
            ▼
           Home
            │
   ┌────────┼────────────┬────────────┐
   │        │            │            │
   ▼        ▼            ▼            ▼
Vocabulary Scenario   AI Free      Learning
 Learning  Conversation Talking      History
   │        │            │            │
   └────────┴──────┬─────┴────────────┘
                   ▼
              Learning Data
                   │
                   ▼
                 Home
```

로그인 결과에 Level Test 기록이 없으면
자동으로 CEFR Level Test로 이동하고,

이미 테스트를 완료한 사용자는 Home 화면으로 이동하도록 구성했습니다.

<br>

---

# 🔐 Authentication

VIPA는 일반 계정 로그인과 Social Login을 지원합니다.

## Email Login

```text
Email
  +
Password
  ↓
FastAPI
  ↓
VIPA JWT
  ↓
Secure Storage
  ↓
Authenticated API
```

### Features

* 이메일 회원가입
* 이메일 / 비밀번호 로그인
* 로그인 Loading State
* 로그인 실패 안내
* JWT 저장
* 인증된 API 요청
* 비밀번호 찾기
* 비밀번호 변경
* 회원 탈퇴

<br>

---

# 🔑 JWT Authentication Flow

Backend에서 전달받은 JWT Access Token은
`FlutterSecureStorage`에 저장합니다.

```text
Login
  ↓
Access Token
  ↓
Flutter Secure Storage
  ↓
Dio Interceptor
  ↓
Authorization Header
```

API 요청 시 Dio Interceptor가 Token을 자동으로 가져와

```http
Authorization: Bearer <ACCESS_TOKEN>
```

형태로 Header에 추가합니다.

또한 API 응답이

```text
401 Unauthorized
```

인 경우 로그인 화면으로 이동하도록 공통 처리했습니다.

<br>

---

# 🌐 Social Login

## Google

```text
Flutter
   ↓
Google Sign-In SDK
   ↓
Google Access Token
   ↓
FastAPI Backend
   ↓
Google User Verification
   ↓
VIPA JWT
```

Google SDK 초기화 시

```text
GOOGLE_WEB_CLIENT_ID
```

를 사용해 Backend 인증용 Token을 획득합니다.

<br>

## Kakao

```text
Flutter
   ↓
Kakao SDK
   ↓
KakaoTalk Login
      or
Kakao Account Login
   ↓
Kakao Access Token
   ↓
FastAPI Backend
   ↓
VIPA JWT
```

기기에 KakaoTalk이 설치되어 있으면 KakaoTalk Login을 우선 시도하고,
사용할 수 없는 경우 Kakao Account Login으로 전환합니다.

<br>

---

# 📧 Password Recovery

비밀번호를 잊은 사용자를 위한 이메일 인증 흐름을 제공합니다.

```text
Email Input
    ↓
Verification Code Request
    ↓
Code Input
    ↓
Code Verification
    ↓
New Password
    ↓
Password Reset
```

화면 단위로

```text
ResetPasswordScreen
        ↓
VerificationCodeScreen
        ↓
ChangePasswordScreen
```

흐름을 구성했습니다.

<br>

---

# 📊 CEFR Level Test

VIPA의 개인화 학습을 시작하기 위한 Level Test 화면입니다.

지원 Level:

```text
A1
A2
B1
B2
C1
C2
```

<br>

## Level Test Flow

```text
Level Test Start
       ↓
GET /level-test/questions
       ↓
20 Questions
       ↓
User Answers
       ↓
POST /level-test/evaluate
       ↓
CEFR Result
       ↓
Result Screen
       ↓
Home
```

Backend에서 생성한 Level Test 문제를 받아 표시하고,
사용자의 모든 답안을 제출한 뒤 분석 결과를 화면에 표시합니다.

### Result Data

```text
CEFR Level
Overall Score
Weakness
Detailed Feedback
```

Backend가 반환한 Level Test 결과는
`LevelTestResult` Model로 변환하여 화면 간 전달에 사용합니다.

<br>

---

# 🏠 Home

로그인 이후 사용자가 가장 먼저 접하는 학습 Dashboard입니다.

### Home Information

* 현재 학습 Rank
* 누적 학습 Energy
* 오늘의 Vocabulary Energy
* 오늘의 Conversation Energy
* 다음 Rank까지 필요한 Energy
* 출석 정보
* 연속 출석
* 학습 진행률
* 학습 통계

<br>

## Learning Rank

학습 활동을 통해 얻은 Energy를 기반으로
현재 사용자의 Rank와 진행도를 표시합니다.

```text
Learning
   ↓
Energy
   ↓
Current Rank
   ↓
Progress
   ↓
Next Rank
```

Rank Card에서는

```text
Total Energy
Today Vocabulary Energy
Today Conversation Energy
Next Rank Requirement
```

등을 확인할 수 있습니다.

<br>

## Home Actions

Home 화면에서 주요 학습 기능으로 바로 이동할 수 있습니다.

```text
오늘의 어휘 학습하기
        ↓
Vocabulary Dashboard


실전회화 학습하기
        ↓
Conversation Category
```

학습 화면에서 Home으로 돌아오면
Backend의 Summary API를 다시 호출하여 최신 학습 상태를 반영합니다.

<br>

---

# 🤖 AI Free Talking

VIPA AI와 자유롭게 영어로 대화할 수 있는 화면입니다.

사용자는

```text
Voice
or
Text
```

두 가지 방식으로 AI와 대화할 수 있습니다.

<br>

## Conversation Flow

```text
User
  ↓
Voice / Text
  ↓
Flutter
  ↓
POST /chat/talk
  ↓
FastAPI
  ↓
AI
  ↓
English Response
Korean Translation
  ↓
Flutter Chat UI
```

<br>

## 🎙️ Speech-to-Text

`speech_to_text`를 활용하여
사용자의 영어 발화를 Text로 변환합니다.

```text
Microphone
    ↓
Permission Request
    ↓
Speech Recognition
    ↓
English Text
    ↓
AI Request
```

설정 Locale:

```text
en_US
```

사용자가 말하는 동안 인식된 문장을 실시간으로 화면에 표시합니다.

<br>

## ⌨️ Text Input

음성 입력이 어려운 환경에서는
Keyboard Mode를 통해 직접 영어 문장을 입력할 수 있습니다.

```text
Voice Mode
    ↕
Text Mode
```

<br>

## 🔊 Text-to-Speech

AI가 반환한 영어 문장은
`flutter_tts`를 이용해 다시 들을 수 있습니다.

```text
AI English Response
        ↓
TTS
        ↓
English Voice
```

TTS 기본 설정:

```text
Language   : en-US
SpeechRate : 0.5
Volume     : 1.0
```

AI 응답이 도착하면 음성으로 재생할 수 있으며
각 AI Message에서 다시 듣기도 가능합니다.

<br>

---

# 🎭 Scenario Conversation

공항, 은행, 병원, 회사 등
실제 상황을 기반으로 AI와 영어 역할극을 진행하는 학습 기능입니다.

<br>

## Category Selection

```text
Main Category
      ↓
Sub Category
      ↓
Scenario
```

Backend의 Category API에서 Main / Sub Category 데이터를 받아와
사용자가 학습하고 싶은 상황을 선택합니다.

예:

```text
공항
 ├─ 출입국 심사
 └─ 수하물 분실

은행
 └─ 계좌 개설

병원
 └─ 진료 접수

회사
 └─ 프로젝트 회의
```

<br>

---

# 🧠 Scenario Generation

사용자가 상황을 선택하면 Backend에서
사용자의 CEFR Level에 맞는 Scenario를 생성합니다.

```text
Sub Category
     ↓
POST /scenario/generate
     ↓
Session ID
Scenario ID
Generated Script
     ↓
Flutter
```

Frontend에서는 생성된 Scenario를 바탕으로
AI Turn과 User Turn을 순서대로 표시합니다.

<br>

---

# 🎙️ Scenario Speaking

사용자는 Scenario에서 영어로 직접 말할 수 있습니다.

```text
AI Sentence
     ↓
User Turn
     ↓
Speech Recognition
     ↓
Recognized English
     ↓
Evaluation
```

`speech_to_text`를 사용하며,

```text
localeId = en_US
```

환경으로 영어 발화를 인식합니다.

실시간 Sound Level도 상태로 관리하여
음성 입력 UI에 반영할 수 있도록 구성했습니다.

<br>

---

# ⌨️ Voice / Text Mode

실전 회화에서도 음성뿐 아니라
Keyboard 입력을 지원합니다.

```text
Speech Mode
    ↕
Text Mode
```

사용자가 상황에 따라 원하는 입력 방식을 선택할 수 있습니다.

<br>

---

# ✅ AI Evaluation

사용자가 말하거나 입력한 영어 문장을 Backend로 전송해
AI 평가 결과를 받습니다.

```text
User English
     ↓
POST /scenario/evaluate
     ↓
AI Evaluation
     ↓
Feedback
     +
Corrected English
```

Frontend에서 표시하는 주요 결과:

```text
feedback_ko
corrected_en
```

즉 단순히

```text
Correct / Wrong
```

만 표시하는 것이 아니라,

* 왜 수정되었는지
* 어떤 문장이 더 자연스러운지

를 함께 확인할 수 있도록 구성했습니다.

<br>

---

# 💡 Progressive Hint System

사용자가 답변하기 어려운 경우
단계적으로 Hint를 받을 수 있습니다.

## Step 1

```text
핵심 Keyword
```

## Step 2

```text
문장의 시작 부분
```

## Step 3

```text
정답 확인 전 Warning
```

## Final

최종 Hint까지 사용한 경우
해당 상태를 평가 요청에 함께 전달합니다.

```text
Hint Level
    ↓
Evaluation
```

각 Turn이 끝나면 Hint 상태는 초기화됩니다.

<br>

---

# 📈 Scenario Progress

Scenario 진행 상태를

```text
Current Turn
     /
Total User Turns
```

기준으로 계산하여 Progress UI에 반영합니다.

```text
Turn 1
 ↓
Turn 2
 ↓
Turn 3
 ↓
...
 ↓
Complete
```

모든 Turn을 완료하면

```text
POST /scenario/complete
```

를 호출하여 Session 결과를 받아옵니다.

<br>

---

# 📚 Vocabulary Learning

사용자의 CEFR Level과 기존 학습 데이터를 기반으로
Vocabulary Quiz를 진행할 수 있습니다.

<br>

## Vocabulary Dashboard

Backend에서 다음 데이터를 받아옵니다.

```text
New Words
Review Words
Retry Words
```

사용자는 학습 시작 전에

```text
새 단어
복습 단어
재도전 단어
```

각각의 학습량을 직접 조절할 수 있습니다.

최대 목표량:

```text
30 Words
```

<br>

---

# 🧩 Personalized Quiz

```text
Vocabulary Dashboard
        ↓
Choose
New / Review / Retry
        ↓
GET /vocabulary/quiz
        ↓
Quiz Session
```

각 문제는 Backend에서 사용자의 CEFR Level과
Vocabulary Study 상태를 기반으로 전달됩니다.

<br>

---

# ✏️ Vocabulary Answer Flow

```text
Question
   ↓
User Input
   ↓
POST /vocabulary/quiz/check
   ↓
Correct?
 │       │
Yes      No
 │       │
 ▼       ▼
Next    Hint
Question │
         ▼
       Retry
```

<br>

## Two-Attempt Flow

Vocabulary Quiz에서는 오답을 바로 종료하지 않고
재도전 기회를 관리합니다.

```text
Attempt 1
    ↓
Wrong
    ↓
Hint
    ↓
Attempt 2
```

Backend가

```text
can_retry
hint_message
target_word
```

등의 데이터를 반환하면
Frontend State에 반영하여 다음 UI를 결정합니다.

<br>

---

# 💡 AI Vocabulary Hint

오답 발생 시 Backend에서 생성한 Hint를 표시합니다.

```text
Wrong Answer
      ↓
Backend
      ↓
AI Hint
      ↓
Flutter
```

단순히 정답을 바로 공개하지 않고
다시 답을 생각할 수 있도록 UI를 구성했습니다.

<br>

---

# 🔊 Vocabulary TTS

Vocabulary 학습에서도 TTS를 사용할 수 있습니다.

```text
English Sentence
      ↓
TTS
      ↓
Pronunciation
```

빈칸 문장의 경우

```text
I would like to ____ a room.
```

처럼 Blank 위치를 기준으로 문장을 나누어 읽고
잠시 Pause를 주는 방식도 구현되어 있습니다.

<br>

---

# ⭐ Bookmark

학습 중 다시 확인하고 싶은 문장은
Bookmark에 저장할 수 있습니다.

```text
Vocabulary
    ↓
Bookmark Toggle
    ↓
Optimistic UI
    ↓
Backend API
```

Bookmark UI는 서버 응답을 기다리기 전에
화면 상태를 먼저 변경하는 **Optimistic UI Update** 방식으로 구성했습니다.

API 요청이 실패할 경우 기존 상태로 Rollback합니다.

<br>

---

# 📊 Vocabulary Result

모든 문제를 완료하면

```text
User Answers
     ↓
POST /vocabulary/quiz/session
     ↓
Result
     ↓
Vocabulary Result Screen
```

순서로 최종 학습 결과를 표시합니다.

<br>

---

# 📚 Learning History

사용자의 학습 기록을 다시 확인할 수 있는 화면입니다.

Learning History 진입 시

```text
Conversation History
Vocabulary History
Bookmarks
```

를 동시에 요청합니다.

```text
Future.wait()
     ↓
┌──────────────┬───────────────┬─────────────┐
│              │               │             │
Conversation Vocabulary      Bookmark
History      History          List
```

하나의 API에 문제가 발생하더라도
다른 History 데이터를 가능한 범위에서 표시하도록 구성했습니다.

<br>

---

# 💬 Conversation History

과거 Scenario Conversation Session을 조회합니다.

```text
GET /conversation/dashboard/history
```

### 제공 정보

* Scenario Title
* Session
* Conversation History
* Correction History

특정 Session을 선택하면

```text
GET /conversation/dashboard/history/{session_id}
```

를 호출하여 전체 대화 Script를 표시합니다.

<br>

---

# 🎧 Conversation Audio Playback

Conversation History 데이터에 Audio URL이 존재하는 경우
`just_audio`를 이용하여 녹음된 음성을 다시 들을 수 있습니다.

### Features

* Play
* Pause
* Stop
* Current Position
* Total Duration
* Progress Indicator

```text
Audio URL
   ↓
just_audio
   ↓
Audio Player UI
```

<br>

---

# 📄 PDF Export & Share

회화 학습 Script를 PDF로 생성하여
외부 앱으로 공유할 수 있습니다.

```text
Conversation Script
        ↓
PDF Document
        ↓
Temporary File
        ↓
Share Plus
        ↓
External App
```

PDF에는

* Scenario Title
* AI English
* AI Korean Translation
* User Expected Expression
* Korean Translation

등의 대화 내용이 포함됩니다.

한국어 PDF 출력을 위해 Nanum Gothic Font를 동적으로 사용합니다.

<br>

---

# 📈 Learning Statistics

학습 이력 화면에서는

* 오늘의 Vocabulary 학습
* 정답률
* 오답 단어
* Bookmark
* Conversation Session

등을 함께 확인할 수 있습니다.

Home 영역에는 `fl_chart` 기반 학습 데이터 시각화 Widget도 구성되어 있습니다.

<br>

---

# 👤 My Page

사용자 계정 및 Profile 정보를 관리합니다.

### Features

* 사용자 Nickname
* Email
* Profile Image
* Profile Edit
* Password Change
* Withdrawal
* Logout

<br>

## Profile Image

`image_picker`를 이용하여
Gallery에서 Profile Image를 선택할 수 있습니다.

```text
Gallery
   ↓
ImagePicker
   ↓
Local Preview
   ↓
Multipart FormData
   ↓
FastAPI
   ↓
Supabase Storage
```

Backend에서 반환된 Profile Image URL과
Local Image Path를 함께 관리합니다.

<br>

---

# 💾 Local Profile Cache

사용자 Profile 정보는 `GetStorage`에도 저장합니다.

```text
Backend Profile
      ↓
GetStorage
      ↓
Local Cache
```

Profile Image는

```text
Local File
   ↓
Remote URL
   ↓
Default Avatar
```

순서로 표시 가능한 데이터를 확인합니다.

Network Error가 발생할 경우
기존 Local Cache를 사용할 수 있도록 구성했습니다.

<br>

---

# 🧭 Navigation

앱의 주요 Route는 `AppRoutes`에서 중앙 관리합니다.

```text
/splash
/login
/signup
/
/history
/conversation
/reset-password
/verification-code
/change-password
/level-test
/level-test-result
/sub-category
/vocabulary-dashboard
/vocabulary
/vocabulary-result
```

화면 전환에는

```text
FadeTransition
200ms
```

을 공통으로 적용합니다.

<br>

---

# 🧩 State Management

VIPA Frontend에서는 기능 특성에 따라
Provider와 GetX를 함께 사용합니다.

## Provider / ChangeNotifier

```text
ConversationProvider
GrammarProvider
VocabularyDashboardProvider
LearningHistoryProvider
```

주로 사용자 Interaction과
복잡한 학습 화면의 State를 관리합니다.

예:

```text
Recording State
Current Turn
Hint Level
Quiz Index
Wrong Answer
Bookmark
Loading
```

<br>

## GetX

```text
HomeController
VocabularyController
```

등에서 Reactive State와 Controller Lifecycle을 관리합니다.

또한

```text
GetMaterialApp
GetStorage
```

를 사용하여 Navigation 지원 및 Local Storage 기능을 활용합니다.

<br>

---

# 🌐 API Architecture

Frontend에서 Backend API 접근을 공통화하기 위해
Dio Instance를 하나의 `ApiService`에서 관리합니다.

```text
Screen
  ↓
Provider / Controller
  ↓
ApiService
  ↓
Dio
  ↓
FastAPI
```

<br>

## Dio Configuration

```text
Base URL
Connect Timeout : 45 sec
Receive Timeout : 45 sec
Content-Type    : application/json
```

<br>

## Request Interceptor

```text
API Request
    ↓
Secure Storage
    ↓
JWT Token
    ↓
Authorization Header
```

<br>

## Response Error Handling

```text
Backend
   ↓
401 Unauthorized
   ↓
Dio Interceptor
   ↓
Login Screen
```

인증 관련 처리를 각 화면마다 반복하지 않고
공통 API Layer에서 처리합니다.

<br>

---

# 🌍 API Environment

현재 `ApiConfig`에서

```text
Local FastAPI
       or
Render Production Server
```

를 선택할 수 있습니다.

### Production

```text
https://vipa-backend.onrender.com/api/v1
```

### Android Emulator Local

```text
http://10.0.2.2:8000/api/v1
```

### Desktop / iOS / Web Local

```text
http://127.0.0.1:8000/api/v1
```

`isLocal` 값을 통해 개발 서버와 배포 서버를 전환합니다.

<br>

---

# 🎨 UI / UX

VIPA는 학습 앱의 주요 기능을 일관된 디자인으로 구성하기 위해
공통 Color System과 Theme를 사용합니다.

### Main Color

```text
Primary
#FF4F39

Accent
#FF7D68

Background
#F3F4F6

Surface
#FFFFFF

Text
#171717
```

<br>

## Typography

```text
Pretendard
```

를 앱 기본 Font로 사용합니다.

<br>

## Design Components

Theme에서 공통으로 관리하는 영역:

* AppBar
* Card
* Input Field
* Elevated Button
* Bottom Navigation
* Color Scheme
* Typography

이를 통해 화면마다 스타일 값을 반복해서 정의하는 것을 줄였습니다.

<br>

---

# 🏗️ Frontend Architecture

```text
Flutter UI
    ↓
Screen
    ↓
Provider / Controller
    ↓
Model
    ↓
ApiService
    ↓
FastAPI Backend
```

Directory를 역할에 따라 분리했습니다.

```text
UI
→ screens/

State / Interaction
→ providers / controllers/

API
→ api/

Data Model
→ models/

External Feature
→ services/

Navigation
→ routes/

Design
→ design/
```

<br>

---

# 📂 Project Structure

```text
Vipa_frontend/
│
├── android/
├── assets/
├── lib/
│   │
│   ├── api/
│   │   ├── api_config.dart
│   │   └── api_service.dart
│   │
│   ├── controllers/
│   │   ├── ai_controller.dart
│   │   ├── auth_controller.dart
│   │   ├── conversation_controller.dart
│   │   ├── home_controller.dart
│   │   ├── level_test_controller.dart
│   │   └── vocabulary_controller.dart
│   │
│   ├── design/
│   │   ├── app_colors.dart
│   │   └── ...
│   │
│   ├── models/
│   │   ├── conversation_category_model.dart
│   │   ├── home_summary_model.dart
│   │   ├── learning_history_models.dart
│   │   ├── level_test_model.dart
│   │   └── vocabulary_dashboard_model.dart
│   │
│   ├── routes/
│   │   └── app_routes.dart
│   │
│   ├── screens/
│   │   ├── ai/
│   │   ├── changepw/
│   │   ├── conversation/
│   │   │   ├── category/
│   │   │   └── chat/
│   │   ├── history/
│   │   ├── home/
│   │   ├── level_test/
│   │   ├── login/
│   │   ├── mypage/
│   │   ├── signup/
│   │   ├── splash/
│   │   └── vocabulary/
│   │
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── tts_service.dart
│   │
│   └── main.dart
│
├── pubspec.yaml
└── README.md
```

<br>

---

# 🛠️ Tech Stack

## Mobile

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge\&logo=dart\&logoColor=white)

<br>

## State Management

![Provider](https://img.shields.io/badge/Provider-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-8A2BE2?style=for-the-badge)

`ChangeNotifier` `Reactive State`

<br>

## Networking

![Dio](https://img.shields.io/badge/Dio-5A29E4?style=for-the-badge)

`REST API` `JSON` `Interceptor` `Multipart`

<br>

## Authentication

![Google](https://img.shields.io/badge/Google%20Sign--In-4285F4?style=for-the-badge\&logo=google\&logoColor=white)
![Kakao](https://img.shields.io/badge/Kakao%20Login-FFCD00?style=for-the-badge\&logo=kakao\&logoColor=000000)

`JWT` `Flutter Secure Storage`

<br>

## Voice

`Speech-to-Text`
`Flutter TTS`
`Permission Handler`

<br>

## Data Visualization

`fl_chart`

<br>

## Storage

`Flutter Secure Storage`
`GetStorage`

<br>

## Media

`Image Picker`
`Just Audio`

<br>

## Document / Share

`PDF`
`Printing`
`Share Plus`
`Path Provider`

<br>

---

# 📦 Main Packages

| Package                  | Purpose                          |
| ------------------------ | -------------------------------- |
| `provider`               | 학습 화면 State 관리                   |
| `get`                    | Reactive Controller / Navigation |
| `get_storage`            | 사용자 Profile 등 Local Cache        |
| `dio`                    | FastAPI REST API 통신              |
| `flutter_secure_storage` | JWT Access Token 저장              |
| `google_sign_in`         | Google Social Login              |
| `kakao_flutter_sdk`      | Kakao Social Login               |
| `speech_to_text`         | 영어 음성 인식                         |
| `permission_handler`     | Microphone Permission            |
| `flutter_tts`            | 영어 음성 출력                         |
| `fl_chart`               | 학습 데이터 Chart                     |
| `image_picker`           | Profile Image 선택                 |
| `just_audio`             | Conversation Audio 재생            |
| `pdf`                    | 학습 Script PDF 생성                 |
| `printing`               | PDF Font / Document Support      |
| `share_plus`             | PDF 외부 공유                        |
| `path_provider`          | Temporary File Path              |
| `flutter_dotenv`         | Social Login 환경변수                |
| `intl`                   | 날짜 / 시간 처리                       |

<br>

---

# 🔌 Backend Integration

VIPA Frontend는 FastAPI Backend와 REST API로 통신합니다.

### Authentication

```text
POST /users/signup
POST /users/login

POST /auth/login/google
POST /auth/login/kakao

POST  /users/password-recovery/send-code
POST  /users/password-recovery/verify-code
PATCH /users/password-recovery/reset
```

<br>

### User

```text
GET   /users/me
PATCH /users/me/profile
PATCH /users/mypage/change-password
DELETE /users/withdraw
```

<br>

### Level Test

```text
GET  /level-test/questions
POST /level-test/evaluate
```

<br>

### Home

```text
GET /home/summary
```

<br>

### AI Free Talking

```text
POST /chat/talk
```

<br>

### Category

```text
GET /category/main-categories
GET /category/sub-categories/{main_cat_id}
```

<br>

### Scenario

```text
POST /scenario/generate
POST /scenario/evaluate
POST /scenario/hint
POST /scenario/complete
```

<br>

### Vocabulary

```text
GET  /vocabulary/dashboard
GET  /vocabulary/quiz
POST /vocabulary/quiz/check
POST /vocabulary/quiz/session
PUT  /vocabulary/{vocab_id}/bookmark

GET /vocabulary/bookmarks
GET /vocabulary/history/today
```

<br>

### Learning History

```text
GET /conversation/dashboard/history

GET
/conversation/dashboard/history/{session_id}
```

<br>

---

# 🔐 Environment Variables

프로젝트 Root에 `.env` 파일을 생성합니다.

```env
KAKAO_NATIVE_APP_KEY=
GOOGLE_WEB_CLIENT_ID=
```

`.env` 파일에는 Social Login과 관련된 Key가 포함되므로
실제 Key는 Public Repository에 Commit하지 않습니다.

<br>

---

# 📱 Android Configuration

현재 Android Application은

```text
minSdk = 24
```

를 기준으로 구성되어 있습니다.

주요 Permission:

```text
INTERNET
RECORD_AUDIO
BLUETOOTH
BLUETOOTH_CONNECT
```

Speech Recognition과 TTS 사용을 위한 Android 설정도 포함되어 있습니다.

<br>

---

# 🚀 Getting Started

## 1. Clone Repository

```bash
git clone https://github.com/VipaForENG/Vipa_frontend.git
cd Vipa_frontend
```

<br>

## 2. Check Flutter

```bash
flutter doctor
```

<br>

## 3. Install Dependencies

```bash
flutter pub get
```

<br>

## 4. Environment Configuration

프로젝트 Root에 `.env` 파일을 생성합니다.

```env
KAKAO_NATIVE_APP_KEY=YOUR_KAKAO_NATIVE_APP_KEY
GOOGLE_WEB_CLIENT_ID=YOUR_GOOGLE_WEB_CLIENT_ID
```

<br>

## 5. Backend Environment

`lib/api/api_config.dart`에서 실행 환경을 확인합니다.

### Production

```dart
static const bool isLocal = false;
```

### Local

```dart
static const bool isLocal = true;
```

<br>

## 6. Run

```bash
flutter run
```

<br>

---

# 🔄 Main Data Flow

```text
User Interaction
      ↓
Flutter Screen
      ↓
Provider / Controller
      ↓
Dio ApiService
      ↓
JWT
      ↓
FastAPI Backend
      ↓
PostgreSQL / AI
      ↓
JSON Response
      ↓
Model / State
      ↓
Flutter UI
```

<br>

---

# 💡 Key Implementation Points

## 1. 사용자 Level과 Frontend Flow 연결

```text
Login
  ↓
is_tested
  ↓
┌─────────────┐
│             │
No           Yes
│             │
▼             ▼
Level Test   Home
```

사용자 데이터 상태에 따라
화면 이동 Flow를 다르게 처리합니다.

<br>

## 2. 공통 Dio API Layer

각 화면에서 별도로 HTTP Client를 만들지 않고

```text
ApiService
```

를 중심으로 API 통신을 공통화했습니다.

이를 통해

```text
Base URL
JWT Header
Timeout
401 Handling
```

을 한곳에서 관리합니다.

<br>

## 3. 음성과 Text를 함께 지원

```text
STT
 +
Keyboard
 +
TTS
```

를 결합하여 사용자가

* 영어를 직접 말하고
* 직접 입력하고
* AI 영어 문장을 다시 들을 수 있도록

구성했습니다.

<br>

## 4. Backend 학습 데이터를 UI State와 연결

Frontend에 고정된 학습 데이터를 사용하는 것이 아니라

```text
Backend
   ↓
Current CEFR
   ↓
Quiz / Scenario / Conversation
   ↓
Frontend
```

흐름으로 Backend에서 결정된 사용자별 학습 데이터를 화면에 반영합니다.

<br>

## 5. 학습 결과 재사용

학습 결과가 한 번 표시되고 끝나는 것이 아니라

```text
Learning
   ↓
Backend Save
   ↓
Home Summary
   +
Learning History
   ↓
Review
```

로 다시 사용자에게 제공됩니다.

<br>

## 6. 학습 Script Export

과거 회화 데이터를 Flutter 화면에서만 확인하는 데 그치지 않고

```text
Backend History
       ↓
Flutter
       ↓
PDF
       ↓
Share
```

형태로 외부 파일까지 만들 수 있도록 구성했습니다.

<br>

---

# 🎯 What Was Implemented

VIPA Frontend를 통해 다음 영역을 구현했습니다.

### Flutter

* Multi-screen Mobile Application
* Material 3 Theme
* Named Route
* Responsive Layout
* Reusable Widget
* Bottom Navigation
* State-driven UI

### State Management

* Provider
* ChangeNotifier
* GetX
* Reactive State
* Loading / Error / Progress State

### Backend Integration

* Dio
* REST API
* JSON Parsing
* Multipart Upload
* JWT Bearer Authentication
* Dio Interceptor
* 401 Handling

### Authentication

* Email Login
* Google Login
* Kakao Login
* Secure Token Storage
* Password Recovery
* Password Change
* Withdrawal

### Voice

* Speech Recognition
* Microphone Permission
* Sound Level
* English TTS

### Learning

* CEFR Level Test
* AI Free Talking
* Scenario Conversation
* AI Evaluation
* Progressive Hint
* Vocabulary Quiz
* Retry Flow
* Bookmark
* Learning History

### Media / Document

* Profile Image
* Audio Playback
* PDF Generation
* PDF Share

<br>

---

# 📈 Project Summary

| Item                   | Description                                  |
| ---------------------- | -------------------------------------------- |
| Project                | VIPA                                         |
| Type                   | Team Project                                 |
| Platform               | Flutter Mobile                               |
| Language               | Dart                                         |
| Frontend Developer     | 송민창                                          |
| GitHub                 | Onin0782                                     |
| Backend                | FastAPI                                      |
| State Management       | Provider / GetX                              |
| Networking             | Dio                                          |
| Authentication         | JWT / Google / Kakao                         |
| Voice                  | STT / TTS                                    |
| Local Storage          | Secure Storage / GetStorage                  |
| Main Learning Standard | CEFR A1 ~ C2                                 |
| Main Features          | Level / AI / Scenario / Vocabulary / History |
| PDF                    | pdf / printing / share_plus                  |

<br>

---

# 🔗 Related Repository

### Backend

https://github.com/VipaForENG/Vipa_backend

<br>

---

# 👨‍💻 Frontend Developer

### 송민창

GitHub
https://github.com/Onin0782
