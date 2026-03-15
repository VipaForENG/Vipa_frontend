// import 'dart:convert';
// import 'package:http/http.dart' as http;
//
// /// [클래스] OxfordApiService
// /// 목적: 옥스포드 사전 API와 통신하여 단어의 정의와 예문을 가져옵니다.
// class OxfordApiService {
//   final String _appId = 'YOUR_APP_ID';   // 발급받은 ID
//   final String _appKey = 'YOUR_APP_KEY'; // 발급받은 KEY
//   final String _baseUrl = 'https://od-api.oxforddictionaries.com/api/v2';
//
//   /// [함수] fetchWordData
//   /// 목적: 특정 단어의 데이터를 사전 API에서 조회합니다.
//   Future<Map<String, dynamic>> fetchWordData(String word) async {
//     final url = Uri.parse('$_baseUrl/entries/en-gb/$word');
//
//     try {
//       final response = await http.get(
//         url,
//         headers: {'app_id': _appId, 'app_key': _appKey},
//       );
//
//       if (response.statusCode == 200) {
//         // [로직] JSON 파싱 후 필요한 핵심 정보(정의, 예문)만 추출해서 반환
//         return json.decode(response.body);
//       } else {
//         throw Exception('단어를 찾을 수 없습니다.');
//       }
//     } catch (e) {
//       throw Exception('API 호출 실패: $e');
//     }
//   }
// }