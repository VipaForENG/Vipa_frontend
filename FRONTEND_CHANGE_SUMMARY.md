# VIPA 프론트엔드 변경 요약

작성일: 2026-06-04

## 전체 방향

- 백엔드는 건드리지 않고 Flutter 프론트엔드 화면과 이동 흐름만 구현했습니다.
- 사용자가 준 시안 기준으로 스플래시, 로그인, 회원가입, 비밀번호 찾기, 레벨테스트, 홈, 실전회화, 오늘의 어휘, 학습내역 화면을 맞췄습니다.
- 로고는 배경까지 쓰지 않고 투명 배경의 로고 이미지만 사용하도록 분리했습니다.

## 인증 화면

- 스플래시 화면 추가
  - `#F09819`에서 `#FF512F`로 이어지는 선형 그라데이션 적용
  - VIPA 로고와 문구 배치
- 로그인 화면 수정
  - VIPA 로고 적용
  - 이메일/비밀번호 입력창, 비밀번호 찾기, 로그인 버튼, 카카오/구글 로그인 버튼 구성
- 회원가입 화면 수정
  - VIPA 로고 적용
  - 이메일/비밀번호/닉네임 입력창과 시작 버튼 구성
- 비밀번호 찾기 흐름 구현
  - 이메일 입력 후 인증번호 받기
  - 인증번호 입력 화면 추가
  - 인증번호 재전송 버튼 추가
  - 인증 성공 후 비밀번호 변경 화면으로 이동
- 비밀번호 변경 화면 수정
  - 새 비밀번호/비밀번호 확인 입력창
  - 비밀번호 변경 버튼 구성

## 레벨테스트

- 최초 로그인 후 레벨테스트 화면 UI 수정
  - 상단 `레벨테스트` 제목
  - 진행바
  - 문제 카드
  - 선택지 버튼 구성
- 레벨테스트 결과 화면 추가/수정
  - 예상 CEFR 레벨 카드
  - 영역별 역량 점수
  - 나의 약점 태그
  - AI 상세 피드백
  - 홈 이동 버튼

## 홈 화면

- 홈 화면을 시안 기준으로 재구성
  - 상단 홈 타이틀과 설정 아이콘
  - 랭크 카드
  - 출석 카드
  - 오늘의 어휘 학습 버튼
  - 실전회화 학습 버튼
- 랭크 시스템 6단계 반영
  - 브론즈
  - 실버
  - 골드
  - 에메랄드
  - 다이아
  - 마스터

## 실전회화 학습 흐름

- 홈의 `실전회화 학습하기` 버튼에서 다음 순서로 이동하도록 구현
  - 실전회화 리스트
  - 실전회화 학습
  - 실전회화 학습완료
- 실전회화 리스트 화면 수정
  - 회화 주제 카드
  - 상세 상황 카드
  - 시작 버튼 구성
- 실전회화 학습 화면 수정
  - 진행바
  - AI 문장 카드
  - 안내 문장 카드
  - 힌트/마이크/키보드 버튼 구성
- 실전회화 학습완료 화면 수정
  - 학습한 상황
  - AI에게 교정받은 문장 개수
  - 교정문장 확인하기 버튼
  - 실전회화로 돌아가기 버튼

## 오늘의 어휘 학습 흐름

- 홈의 `오늘은 어떤 어휘를 배워볼까요?` 버튼에서 다음 순서로 이동하도록 구현
  - 오늘의 어휘 학습목표
  - 오늘의 어휘 학습
  - 오늘의 어휘 학습완료
- 오늘의 어휘 학습목표 화면 수정
  - 새로운 단어 수 선택 카드
  - 복습할 단어 수 선택 카드
  - 재도전 단어 수 선택 카드
  - 세 카드 모두 옆으로 넘기는 슬라이드 방식 적용
  - 숫자/문구 글자 크기 조정
- 오늘의 어휘 학습 화면 수정
  - 진행바
  - 문제 카드
  - 빈칸 입력 방식 구성
- 오늘의 어휘 학습완료 화면 수정
  - 총 문항
  - 정답 개수
  - 정답률
  - 틀린 어휘 확인하기 버튼
  - 오늘의 어휘로 돌아가기 버튼

## 학습내역

- 학습내역 메인 화면 구현
  - `실전회화`
    - AI가 교정한 문장
    - 상황별 시나리오
  - `오늘의 어휘`
    - 즐겨찾기한 문장
    - 오답 단어
- `AI가 교정한 문장` 페이지 구현
  - 학습내역 탭 안에서 열리도록 처리
  - 카드에 문장 제목과 날짜 표시
- `상황별 시나리오` 페이지 구현
  - 학습내역 탭 안에서 열리도록 처리
  - 카드에 문장 제목과 날짜 표시
  - 오른쪽에 PDF 표시 추가
- 하단 탭이 마이페이지로 헷갈리지 않도록 학습내역 탭 내부 전환 방식으로 수정

## 추가된 주요 파일

- `assets/images/vipa_logo_mark.png`
- `lib/screens/splash/splash_screen.dart`
- `lib/screens/login/auth_widgets.dart`
- `lib/screens/login/verification_code_screen.dart`
- `FRONTEND_CHANGE_SUMMARY.md`

## 수정된 주요 파일

- `lib/main.dart`
- `lib/routes/app_routes.dart`
- `lib/screens/login/login_screen.dart`
- `lib/screens/signup/signup_screen.dart`
- `lib/screens/login/reset_password_screen.dart`
- `lib/screens/changepw/change_password_screen.dart`
- `lib/screens/level_test/level_test_screen.dart`
- `lib/screens/level_test/level_test_result_screen.dart`
- `lib/screens/home/home_screen.dart`
- `lib/screens/conversation/category/category_selection_screen.dart`
- `lib/screens/conversation/chat/conversation_chat_screen.dart`
- `lib/screens/conversation/chat/conversation_result_screen.dart`
- `lib/screens/vocabulary/vocabulary_dashboard_screen.dart`
- `lib/screens/vocabulary/vocabulary_dashboard_provider.dart`
- `lib/screens/vocabulary/vocabulary_screen.dart`
- `lib/screens/vocabulary/vocabulary_result_screen.dart`
- `lib/screens/history/learning_history_screen.dart`

## 확인 사항

- 현재 작업은 코드 파일에 저장되어 있습니다.
- Flutter/Dart 명령은 이 환경에서 여러 번 타임아웃이 발생해 실행 검증은 완료하지 못했습니다.
- 백엔드 로직은 수정하지 않았습니다.
