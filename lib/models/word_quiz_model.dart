// /// [클래스] WordQuizModel
// /// 목적: API에서 가져온 데이터를 퀴즈용으로 규격화합니다.
// class WordQuizModel {
//   final String word;
//   final String definition;
//   final String example;
//
//   WordQuizModel({
//     required this.word,
//     required this.definition,
//     required this.example,
//   });
//
//   // [함수] fromJson: API 응답 JSON을 모델로 변환
//   factory WordQuizModel.fromJson(Map<String, dynamic> json) {
//     // [로직] JSON 구조에 맞춰 파싱 (API 응답 필드에 따라 조정 필요)
//     return WordQuizModel(
//       word: json['word'],
//       definition: json['results'][0]['lexicalEntries'][0]['entries'][0]['senses'][0]['definitions'][0],
//       example: json['results'][0]['lexicalEntries'][0]['entries'][0]['senses'][0]['examples'][0]['text'],
//     );
//   }
// }