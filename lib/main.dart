// [임포트] Flutter UI 개발을 위한 핵심 Material 패키지입니다.
import 'package:flutter/material.dart';
// [임포트] 상태 관리를 위한 provider 패키지입니다.
import 'package:provider/provider.dart';
// [임포트] 우리가 정의한 앱 내 화면 이동 경로(라우트) 관리 파일입니다.
import 'routes/app_routes.dart';

// [임포트] 우리가 정의한 각 화면의 로직 및 상태 관리 파일들입니다.
import 'screens/grammar/grammar_provider.dart';
import 'screens/conversation/conversation_provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// [임포트] 카카오 로그인 SDK 패키지입니다.
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

// [함수] main
// 목적: 앱의 실행을 시작하는 진입점(Entry Point)입니다.
void main() async {
  // [로직] Flutter 엔진과 위젯 트리가 바인딩되기 전에 초기화를 보장합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // [로직] 숨겨둔 .env 파일을 불러옵니다.
  await dotenv.load(fileName: ".env");

  // [로직] 불러온 환경 변수 값으로 카카오 SDK를 초기화합니다.
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '');
  // [로직] runApp은 Flutter 앱을 구동하고 최상위 위젯을 화면에 띄웁니다.
  runApp(const VipaApp());
}

// [클래스] VipaApp
// 목적: 앱의 최상위 루트 위젯입니다. 전체적인 테마와 라우팅(화면 이동) 방식을 설정합니다.
class VipaApp extends StatelessWidget {
  // 생성자: 위젯 식별을 위한 키를 부모 클래스에 전달합니다.
  const VipaApp({super.key});

  // [함수] build
  // 목적: 앱의 전체 구조인 MaterialApp을 설계합니다.
  // 인자: context - 위젯 트리의 위치 정보
  @override
  Widget build(BuildContext context) {
    // [위젯] MultiProvider: 앱 전체에서 사용할 여러 개의 상태(Provider)를 등록합니다.
    return MultiProvider(
      providers: [
        // 오늘의 어휘/문법 화면을 위한 상태 관리
        ChangeNotifierProvider(create: (_) => GrammarProvider()),
        // 대화 연습 화면을 위한 상태 관리
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
      ],
      // [위젯] MaterialApp: 앱의 이름, 테마, 라우팅 등 핵심 설정을 포함합니다.
      child: MaterialApp(
        title: 'vipa', // 앱의 실행 제목
        debugShowCheckedModeBanner: false, // 개발 시 오른쪽 상단 DEBUG 리본을 숨깁니다.
        // [테마] 앱 전반의 색상 체계와 Material 3 디자인 적용
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),

        // [경로] 초기 화면 경로를 설정합니다.
        // 만약 로그인을 먼저 띄우고 싶다면 AppRoutes.login 등으로 변경하세요.
        initialRoute: AppRoutes.login,

        // [경로] 별도 정의된 라우트 맵(AppRoutes.getRoutes)을 연결하여 화면 이동을 처리합니다.
        routes: AppRoutes.getRoutes(),
      ),
    );
  }
}
