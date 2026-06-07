// [임포트] Flutter 프레임워크의 기본 UI 구성 요소들을 가져옵니다.
import 'package:flutter/material.dart';
// [임포트] 앱 전체의 상태 관리(Provider)를 효율적으로 하기 위한 패키지입니다.
import 'package:provider/provider.dart';
// [임포트] 우리가 정의한 화면 이동 경로와 전환 애니메이션 설정 파일입니다.
import 'routes/app_routes.dart'; 
import 'package:get/get.dart';
// [임포트] 문법 학습 관련 데이터와 상태를 관리하는 프로바이더입니다.
import 'screens/vocabulary/vocabulary_provider.dart';

import 'screens/vocabulary/vocabulary_dashboard_provider.dart';

// [임포트] 회화 연습 관련 데이터와 상태를 관리하는 프로바이더입니다.
import 'screens/conversation/chat/conversation_provider.dart';
// [임포트] 보안이 필요한 키(API KEY 등)를 .env 파일에서 불러오기 위한 패키지입니다.
import 'package:flutter_dotenv/flutter_dotenv.dart';
// [임포트] 카카오 소셜 로그인을 사용하기 위한 SDK 패키지입니다.
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'package:get_storage/get_storage.dart'; // [추가] 간단한 로컬 저장소 패키지입니다. 토큰 저장 등에 사용됩니다.

/// [함수] main
/// 앱의 실행이 시작되는 가장 첫 번째 지점입니다.
/// 비동기 작업(await)이 포함되므로 async 키워드가 붙습니다.
void main() async {
  await GetStorage.init(); // 👈 이 줄이 반드시 있어야 합니다!
  // [초기화 보장] Flutter 엔진과 위젯 트리가 완전히 준비될 때까지 기다립니다.
  // 비동기 데이터를 다루기 전 반드시 실행해야 하는 필수 코드입니다.
  WidgetsFlutterBinding.ensureInitialized();

  // [환경 변수 로드] 프로젝트 루트에 있는 .env 파일을 읽어와서 앱 내에서 쓸 준비를 합니다.
  // 이 파일에는 카카오 키 등 노출되면 안 되는 보안 정보가 들어있습니다.
  await dotenv.load(fileName: ".env");

  // [카카오 SDK 초기화] .env 파일에서 가져온 'KAKAO_NATIVE_APP_KEY'를 사용하여
  // 카카오 로그인 기능을 사용할 수 있도록 초기화합니다. 만약 키가 없다면 빈 문자열을 전달합니다.
  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '');
  
  // [앱 실행] 최상위 위젯인 VipaApp을 실행하여 화면을 띄웁니다.
  runApp(const VipaApp());
}

/// [클래스] VipaApp
/// 앱의 뼈대를 형성하는 최상위 위젯입니다.
class VipaApp extends StatelessWidget {
  const VipaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GrammarProvider()),
        ChangeNotifierProvider(create: (_) => ConversationProvider()),
        ChangeNotifierProvider(create: (_) => VocabularyDashboardProvider()),
      ],
      // [위젯] GetMaterialApp: GetX의 기능을 사용하기 위한 최상위 위젯입니다.
      child: GetMaterialApp(
        title: 'vipa',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        initialRoute: AppRoutes.splash,
        // GetX를 사용하므로 AppRoutes.onGenerateRoute를 통해 경로를 관리합니다.
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
